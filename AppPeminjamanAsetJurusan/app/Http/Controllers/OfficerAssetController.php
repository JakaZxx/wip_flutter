<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Commodity;
use App\Http\Requests\AssetRequest;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use App\Models\Student;

class OfficerAssetController extends Controller
{
    public function index(Request $request)
    {
        $user = Auth::user();

        // Ambil input dari search bar
        $search = $request->input('search');

        // Query dasar - filter by officer's jurusan, exclude stock 0
        $query = Commodity::where('jurusan', $user->jurusan)->where('stock', '>', 0);

        // Jika ada pencarian (nama atau kode)
        if (!empty($search)) {
            $query->where(function($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('code', 'like', "%{$search}%");
            });
        }

        // Pagination
        $perPage = 5;
        $assets = $query->orderBy('id', 'desc')->paginate($perPage);

        // Get cart quantities from Cart model
        $cart = \App\Models\Cart::getOrCreateForUser(auth()->id());
        $cartItems = $cart->items()->get();
        $cartQuantities = $cartItems->pluck('quantity', 'commodity_id')->toArray();

        // Get students data for borrowing form
        $students = Student::with('schoolClass', 'user')->get();

        // Fetch unread notifications for officer with enriched data and filtering
        $notifications = $user->notifications()
            ->whereNull('read_at')
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

        return view('officers.assets.index', compact('assets', 'cartQuantities', 'students', 'notifications', 'unreadCount'));
    }



    public function create()
    {
        return view('officers.assets.create');
    }

    public function store(Request $request)
    {
        $user = Auth::user();

        $data = $request->validate([
            'name' => 'required|string|max:255',
            'code' => 'required|string|max:255|unique:commodities,code',
            'stock' => 'required|integer|min:0',
            'lokasi' => 'required|string',
            'photo' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:10000',
        ]);

        $data['jurusan'] = $user->jurusan;

        if ($request->hasFile('photo')) {
            $path = $request->file('photo')->store('commodities', 'public');
            $data['photo'] = $path; // Will store 'commodities/filename.jpg'
        }

        Commodity::create($data);

        return redirect()->route('officers.assets.index')
                         ->with('success', 'Barang berhasil ditambahkan.');
    }

    public function edit($id)
    {
        $commodity = Commodity::findOrFail($id);
        $user = Auth::user();

        // Allow editing if:
        // 1. Officer has no specific jurusan assigned (NULL) - can edit any asset
        // 2. Officer's jurusan matches the commodity's jurusan
        // 3. Officer is an admin (though this should be handled by middleware)
        if ($user->jurusan !== null && $commodity->jurusan !== $user->jurusan) {
            return redirect()->route('officers.assets.index')->with('error', 'Anda tidak memiliki akses untuk mengedit barang ini.');
        }

        return view('officers.assets.edit', compact('commodity'));
    }

    public function update(Request $request, $id)
    {
        $commodity = Commodity::findOrFail($id);
        $user = Auth::user();

        $data = $request->validate([
            'name' => 'required|string|max:255',
            'code' => 'required|string|max:255|unique:commodities,code,' . $commodity->id,
            'stock' => 'required|integer|min:0',
            'lokasi' => 'required|string',  
            'photo' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:10000',
        ]);

        $data['jurusan'] = $user->jurusan;

        if ($request->hasFile('photo')) {
            // Delete old photo if it exists
            if ($commodity->photo) {
                Storage::disk('public')->delete($commodity->photo);
            }

            $path = $request->file('photo')->store('commodities', 'public');
            $data['photo'] = $path;
        }

        $commodity->update($data);

        return redirect()->route('officers.assets.index')
                         ->with('success', 'Barang berhasil diperbarui.');
    }

    public function destroy($id)
    {
        $commodity = Commodity::findOrFail($id);
        $commodity->delete();
        return redirect()->route('officers.assets.index')->with('success', 'Barang berhasil dihapus.');
    }

    public function detail($id)
    {
        try {
            $commodity = Commodity::findOrFail($id);
            return response()->json([
                'success' => true,
                'asset' => $commodity
            ]);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json(['success' => false, 'message' => 'Aset tidak ditemukan.'], 404);
        }
    }
}
