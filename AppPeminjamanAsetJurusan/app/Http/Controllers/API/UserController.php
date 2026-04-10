<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller; // Mengimpor Controller dasar Laravel
use App\Models\User; // Mengimpor model User
use App\Models\Student; // Mengimpor model Student
use Illuminate\Http\Request; // Mengimpor Request
use Illuminate\Support\Facades\Hash; // Mengimpor Hash untuk password
use Illuminate\Support\Facades\Validator; // Mengimpor Validator
use Illuminate\Support\Facades\Log;

class UserController extends Controller
{
    /**
     * Get authenticated user profile
     */
    public function profile()
    {
        Log::info('UserController::profile started');
        try {
            $user = auth('sanctum')->user();
            if (!$user) {
                Log::warning('UserController::profile user not authenticated');
                Log::info('UserController::profile ended');
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $user->load('student.schoolClass');

            Log::info('UserController::profile ended successfully');
            return response()->json([
                'success' => true,
                'message' => 'Profile fetched successfully',
                'data' => $user
            ]);
        } catch (\Exception $e) {
            Log::error('UserController::profile error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            Log::info('UserController::profile ended with error');
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan saat mengambil profil'
            ], 500);
        }
    }

    /**
     * Update authenticated user profile (photo only)
     */
    public function updateProfile(Request $request)
    {
        Log::info('UserController::updateProfile started');
        try {
            $user = auth('sanctum')->user();
            if (!$user) {
                Log::warning('UserController::updateProfile user not authenticated');
                Log::info('UserController::updateProfile ended');
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            // Validator only for profile_picture
            $validator = Validator::make($request->all(), [
                'profile_picture' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048' // 2MB max
            ]);

            if ($validator->fails()) {
                Log::warning('UserController::updateProfile validation failed', ['errors' => $validator->errors()]);
                Log::info('UserController::updateProfile ended');
                return response()->json([
                    'success' => false,
                    'message' => 'Validasi gagal: ' . $validator->errors()->first(),
                    'data' => null
                ], 400);
            }

            // Handle profile picture upload
            if ($request->hasFile('profile_picture') && $request->file('profile_picture')->isValid()) {
                // Delete old image if exists
                if ($user->profile_picture && file_exists(public_path('storage/profiles/' . $user->profile_picture))) {
                    unlink(public_path('storage/profiles/' . $user->profile_picture));
                }

                // Store new image
                $file = $request->file('profile_picture');
                $filename = time() . '_' . $file->getClientOriginalName();
                $file->storeAs('profiles', $filename, 'public');

                $user->profile_picture = $filename;
                $user->save();
            }

            // Reload user to get updated data
            $user->load('student.schoolClass');

            Log::info('UserController::updateProfile ended successfully');
            return response()->json([
                'success' => true,
                'message' => 'Profile updated successfully',
                'data' => $user
            ]);
        } catch (\Exception $e) {
            Log::error('UserController::updateProfile error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            Log::info('UserController::updateProfile ended with error');
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan saat memperbarui profil'
            ], 500);
        }
    }

    /**
     * Menampilkan semua data user.
     * Metode ini untuk endpoint GET /api/users.
     */
    public function index()
    {
        Log::info('UserController::index started');
        try {
            // Mengambil semua user dengan relasi student
            $users = User::with('student')->get();

            Log::info('UserController::index ended successfully');
            return response()->json([
                'success' => true,
                'message' => 'Data user berhasil diambil',
                'data' => $users
            ]);
        } catch (\Exception $e) {
            Log::error('UserController::index error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            Log::info('UserController::index ended with error');
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan saat mengambil data user'
            ], 500);
        }
    }

    /**
     * Menambahkan user baru.
     * Metode ini untuk endpoint POST /api/users.
     */
    public function store(Request $request)
    {
        Log::info('UserController::store started');
        try {
            // Validasi input
            $validator = Validator::make($request->all(), [
                'name' => 'required|string|max:255',
                'email' => 'required|email|unique:users,email',
                'password' => 'required|string|min:8',
                'role' => 'required|string|in:admin,officers,students',
                'school_class_id' => 'required_if:role,students|exists:school_classes,id',
                'jurusan' => 'nullable|string|max:255',
                'nis' => 'nullable|string|max:255',
                'approval_status' => 'nullable|string|in:pending,approved,rejected'
            ]);

            if ($validator->fails()) {
                Log::warning('UserController::store validation failed', ['errors' => $validator->errors()]);
                Log::info('UserController::store ended');
                return response()->json([
                    'success' => false,
                    'message' => 'Validasi gagal: ' . $validator->errors()->first(),
                    'data' => null
                ], 400);
            }

            // Hash password sebelum simpan
            $data = $request->all();
            $data['password'] = Hash::make($request->password);

            // Buat user baru
            $user = User::create($data);

            // Jika role adalah students, buat record student
            if ($user->role === 'students') {
                Student::create([
                    'user_id' => $user->id,
                    'school_class_id' => $request->school_class_id,
                    'name' => $user->name
                ]);
            }

            Log::info('UserController::store ended successfully');
            return response()->json([
                'success' => true,
                'message' => 'User berhasil ditambahkan',
                'data' => $user
            ], 201);
        } catch (\Exception $e) {
            Log::error('UserController::store error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            Log::info('UserController::store ended with error');
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan saat menambahkan user'
            ], 500);
        }
    }

    /**
     * Memperbarui data user berdasarkan ID.
     * Metode ini untuk endpoint PUT /api/users/{id}.
     */
    public function update(Request $request, $id)
    {
        Log::info('UserController::update started');
        try {
            // Cari user berdasarkan ID
            $user = User::find($id);

            if (!$user) {
                Log::warning('UserController::update user not found', ['user_id' => $id]);
                Log::info('UserController::update ended');
                return response()->json([
                    'success' => false,
                    'message' => 'User tidak ditemukan',
                    'data' => null
                ], 404);
            }

            // Validasi input, email unique kecuali untuk user ini
            $validator = Validator::make($request->all(), [
                'name' => 'required|string|max:255',
                'email' => 'required|email|unique:users,email,' . $id,
                'password' => 'nullable|string|min:8',
                'role' => 'nullable|string|in:admin,officers,students',
                'jurusan' => 'nullable|string|max:255',
                'nis' => 'nullable|string|max:255',
                'approval_status' => 'nullable|string|in:pending,approved,rejected',
                'profile_picture' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048' // 2MB max
            ]);

            if ($validator->fails()) {
                Log::warning('UserController::update validation failed', ['errors' => $validator->errors(), 'user_id' => $id]);
                Log::info('UserController::update ended');
                return response()->json([
                    'success' => false,
                    'message' => 'Validasi gagal: ' . $validator->errors()->first(),
                    'data' => null
                ], 400);
            }

            // Update data
            $data = $request->all();
            if ($request->has('password') && !empty($request->password)) {
                $data['password'] = Hash::make($request->password);
            } else {
                unset($data['password']); // Jangan update password jika tidak disediakan
            }

            // Handle profile picture upload
            if ($request->hasFile('profile_picture') && $request->file('profile_picture')->isValid()) {
                // Delete old image if exists
                if ($user->profile_picture && file_exists(public_path('storage/profiles/' . $user->profile_picture))) {
                    unlink(public_path('storage/profiles/' . $user->profile_picture));
                }

                // Store new image
                $file = $request->file('profile_picture');
                $filename = time() . '_' . $file->getClientOriginalName();
                $file->storeAs('profiles', $filename, 'public');

                $data['profile_picture'] = $filename;
            }

            $user->update($data);

            // Reload user to get updated data
            $user->load('student.schoolClass');

            Log::info('UserController::update ended successfully');
            return response()->json([
                'success' => true,
                'message' => 'User berhasil diperbarui',
                'data' => $user
            ]);
        } catch (\Exception $e) {
            Log::error('UserController::update error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString(), 'user_id' => $id]);
            Log::info('UserController::update ended with error');
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan saat memperbarui user'
            ], 500);
        }
    }

    /**
     * Menghapus user berdasarkan ID.
     * Metode ini untuk endpoint DELETE /api/users/{id}.
     */
    public function destroy($id)
    {
        Log::info('UserController::destroy started');
        try {
            // Cari user berdasarkan ID
            $user = User::find($id);

            if (!$user) {
                Log::warning('UserController::destroy user not found', ['user_id' => $id]);
                Log::info('UserController::destroy ended');
                return response()->json([
                    'success' => false,
                    'message' => 'User tidak ditemukan',
                    'data' => null
                ], 404);
            }

            // Hapus user
            $user->delete();

            Log::info('UserController::destroy ended successfully');
            return response()->json([
                'success' => true,
                'message' => 'User berhasil dihapus',
                'data' => null
            ]);
        } catch (\Exception $e) {
            Log::error('UserController::destroy error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString(), 'user_id' => $id]);
            Log::info('UserController::destroy ended with error');
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan saat menghapus user'
            ], 500);
        }
    }

    /**
     * Approve user berdasarkan ID.
     * Metode ini untuk endpoint PATCH /api/users/{id}/approve.
     */
    public function approve($id)
    {
        Log::info('UserController::approve started');
        try {
            // Cari user berdasarkan ID
            $user = User::find($id);

            if (!$user) {
                Log::warning('UserController::approve user not found', ['user_id' => $id]);
                Log::info('UserController::approve ended');
                return response()->json([
                    'success' => false,
                    'message' => 'User tidak ditemukan',
                    'data' => null
                ], 404);
            }

            // Update approval status
            $user->update(['approval_status' => 'approved']);

            // Reload user to get updated data
            $user->load('student.schoolClass');

            Log::info('UserController::approve ended successfully');
            return response()->json([
                'success' => true,
                'message' => 'User berhasil diapprove',
                'data' => $user
            ]);
        } catch (\Exception $e) {
            Log::error('UserController::approve error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString(), 'user_id' => $id]);
            Log::info('UserController::approve ended with error');
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan saat approve user'
            ], 500);
        }
    }

    /**
     * Reject user berdasarkan ID.
     * Metode ini untuk endpoint PATCH /api/users/{id}/reject.
     */
    public function reject($id)
    {
        Log::info('UserController::reject started');
        try {
            // Cari user berdasarkan ID
            $user = User::find($id);

            if (!$user) {
                Log::warning('UserController::reject user not found', ['user_id' => $id]);
                Log::info('UserController::reject ended');
                return response()->json([
                    'success' => false,
                    'message' => 'User tidak ditemukan',
                    'data' => null
                ], 404);
            }

            // Update approval status
            $user->update(['approval_status' => 'rejected']);

            // Reload user to get updated data
            $user->load('student.schoolClass');

            Log::info('UserController::reject ended successfully');
            return response()->json([
                'success' => true,
                'message' => 'User berhasil direject',
                'data' => $user
            ]);
        } catch (\Exception $e) {
            Log::error('UserController::reject error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString(), 'user_id' => $id]);
            Log::info('UserController::reject ended with error');
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan saat reject user'
            ], 500);
        }
    }
}
