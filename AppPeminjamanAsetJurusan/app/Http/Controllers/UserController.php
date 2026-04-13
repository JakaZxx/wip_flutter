<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Student;
use App\Models\SchoolClass;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class UserController extends Controller
{
    // Display a listing of users
    public function index(Request $request)
    {
        // Ambil input dari search bar & filter dropdown
        $search = $request->input('search');
        $role = $request->input('role');

        // Query dasar
        $query = User::with('student.schoolClass');

        // Jika ada pencarian (nama atau email)
        if (!empty($search)) {
            $query->where(function($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%");
            });
        }

        // Jika filter role dipilih
        if (!empty($role)) {
            $query->where('role', $role);
        }

        // Pagination
        $users = $query->orderBy('id','desc')->paginate(10)->appends(request()->query());

        // Ambil daftar role unik untuk dropdown filter
        $roleList = User::select('role')->distinct()->pluck('role');

        return view('admin.users.index', compact('users', 'roleList'));
    }

    // Approve a user (for officers)
    public function approve(User $user)
    {
        if ($user->role === 'officers' && $user->approval_status === 'pending') {
            $user->update(['approval_status' => 'approved']);
            return redirect()->route('users.index')->with('success', 'Officer approved successfully.');
        }
        return redirect()->route('users.index')->with('error', 'Unable to approve this user.');
    }

    // Reject a user (for officers)
    public function reject(User $user)
    {
        if ($user->role === 'officers' && $user->approval_status === 'pending') {
            $user->update(['approval_status' => 'rejected']);
            return redirect()->route('users.index')->with('success', 'Officer rejected successfully.');
        }
        return redirect()->route('users.index')->with('error', 'Unable to reject this user.');
    }

    // Show the form for creating a new user
    public function create()
    {
        // ambil semua kelas untuk dropdown
        $schoolClasses = SchoolClass::all();
        return view('admin.users.create', compact('schoolClasses'));
    }

    // Store a newly created user
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'role' => 'required|in:admin,students,officers',
            'jurusan' => 'required_if:role,officers|nullable|string',
            'password' => 'required|string|min:8|confirmed',
            'school_class_id' => 'required_if:role,students|nullable|exists:school_classes,id',
        ]);

        if ($validator->fails()) {
            return redirect()->back()->withErrors($validator)->withInput();
        }

        // Simpan ke tabel users
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'role' => $request->role,
            'jurusan' => $request->jurusan,
            'password' => bcrypt($request->password),
        ]);

        // Jika role student, simpan juga ke tabel students
        if ($request->role === 'students') {
            Student::create([
                'name' => $request->name,
                'school_class_id' => $request->school_class_id,
                'user_id' => $user->id,
            ]);
        }

        return redirect()->route('users.index')->with('success', 'User created successfully.');
    }

    // Show the form for editing the specified user
    public function edit(User $user)
    {
        $schoolClasses = SchoolClass::all();
        return view('admin.users.edit', compact('user', 'schoolClasses'));
    }

    // Update the specified user
    public function update(Request $request, User $user)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users,email,' . $user->id,
            'role' => 'required|in:admin,students,officers',
            'school_class_id' => 'required_if:role,students|nullable|exists:school_classes,id',
        ]);

        if ($validator->fails()) {
            return redirect()->back()->withErrors($validator)->withInput();
        }

        // Update data di users
        $user->update([
            'name' => $request->name,
            'email' => $request->email,
            'role' => $request->role,
        ]);

        // Kalau student, update atau buat data students
        if ($request->role === 'students') {
            $user->student()->updateOrCreate(
                ['user_id' => $user->id],
                [
                    'name' => $request->name,
                    'school_class_id' => $request->school_class_id,
                ]
            );
        } else {
            // Kalau bukan student, hapus data students terkait
            $user->student()->delete();
        }

        return redirect()->route('users.index')->with('success', 'User updated successfully.');
    }

    // Remove the specified user
    public function destroy(User $user)
    {
        // Hapus juga student terkait jika ada
        $user->student()->delete();
        $user->delete();

        return redirect()->route('users.index')->with('success', 'User deleted successfully.');
    }

    // Show user profile
    public function profile()
    {
        $user = auth()->user();
        return view('profile', compact('user'));
    }

    // Update user profile
    public function updateProfile(Request $request)
    {
        $user = auth()->user();

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users,email,' . $user->id,
            'profile_picture' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:10000',
        ]);

        if ($validator->fails()) {
            return redirect()->back()->withErrors($validator)->withInput();
        }

        $data = [
            'name' => $request->name,
            'email' => $request->email,
        ];

        if ($request->hasFile('profile_picture')) {
            $file = $request->file('profile_picture');
            $filename = time() . '.' . $file->getClientOriginalExtension();
            // Store in storage/app/public/profile_pictures
            $path = $file->storeAs('profile_pictures', $filename, 'public');
            $data['profile_picture'] = $path; // Will store 'profile_pictures/filename.jpg'
        }

        $user->update($data);

        // Redirect back to profile page with success message
        return redirect()->back()->with('success', 'Profil berhasil disimpan');
    }

    // Delete profile picture
    public function deleteProfilePicture(Request $request)
    {
        $user = auth()->user();

        if ($user->profile_picture && file_exists(public_path($user->profile_picture))) {
            unlink(public_path($user->profile_picture));
        }

        $user->profile_picture = null;
        $user->save();

        return redirect()->back()->with('success', 'Profile picture deleted successfully.');
    }

    // Delete user profile
    public function deleteProfile(Request $request)
    {
        $user = auth()->user();

        // Log out the user before deleting
        auth()->logout();

        // Delete the user record
        $user->delete();

        // Invalidate the session
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        // Redirect to home or login page
        return redirect('/')->with('success', 'Profile deleted successfully.');
    }

    // Mark notification as read
    public function markNotificationAsRead($id)
    {
        $user = auth()->user();
        $notification = $user->notifications()->where('id', $id)->first();

        if ($notification) {
            $notification->markAsRead();
            return response()->json(['success' => true]);
        }

        return response()->json(['success' => false], 404);
    }

    // Get notifications for current user
    public function getNotifications()
    {
        $user = auth()->user();
        $notifications = $user->notifications()
            ->whereNull('read_at')
            ->orderBy('created_at', 'desc')
            ->take(10)
            ->get()
            ->map(function ($notification) {
                $data = $notification->data;
                $message = $data['requestDetails']['message'] ?? ($data['message'] ?? 'Notifikasi baru');
                $link = $data['link'] ?? '#';
                $sender = $notification->sender_id ? \App\Models\User::find($notification->sender_id) : null;
                return (object)[
                    'id' => $notification->id,
                    'message' => $message,
                    'link' => $link,
                    'is_read' => $notification->read_at ? true : false,
                    'created_at' => $notification->created_at,
                    'sender' => $sender,
                ];
            });
        $unreadCount = $user->notifications()->whereNull('read_at')->count();

        return response()->json([
            'notifications' => $notifications,
            'unreadCount' => $unreadCount
        ]);
    }
}