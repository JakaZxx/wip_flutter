<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Commodity;
use App\Http\Requests\AssetRequest;
use Illuminate\Support\Facades\Storage;

class AdminAssetController extends Controller
{
    public function index(Request $request)
    {
        $jurusan = $request->input('jurusan');
        $viewAll = $request->input('view_all');

        // Redirect to jurusan selection if no jurusan query param and not viewing all
        if (empty($jurusan) && empty($viewAll)) {
            return redirect()->route('admin.assets.selectJurusan');
        }

        // Ambil input dari search bar & filter dropdown
        $search   = $request->input('search');

        // Query dasar (tampilkan semua termasuk stock 0)
        $query = Commodity::query();

        // Jika ada pencarian (nama atau kode barang)
        if (!empty($search)) {
            $query->where(function($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('code', 'like', "%{$search}%");
            });
        }

        // Filter by jurusan selected (works in both normal and view_all mode)
        if (!empty($jurusan)) {
            $query->where('jurusan', $jurusan);
        }

        // Pagination
        $assets = $query->orderBy('id','desc')->paginate(12)->appends(request()->query());

        // Ambil daftar jurusan unik untuk dropdown filter
        $jurusanList = Commodity::select('jurusan')->distinct()->pluck('jurusan');

        // Jika kosong, gunakan daftar default
        if ($jurusanList->isEmpty()) {
            $jurusanList = collect(['Rekayasa Perangkat Lunak', 'Desain Komunikasi Visual', 'Teknik Otomasi Industri', 'Teknik Instalasi Tenaga Listrik', 'Teknik Audio Video', 'Teknik Komputer Jaringan']);
        }

        return view('admin.assets.index', compact('assets', 'jurusanList', 'jurusan', 'viewAll'));
    }

    public function selectJurusan()
    {
        $jurusanList = Commodity::select('jurusan')->distinct()->pluck('jurusan');

        // Jika kosong, gunakan daftar default
        if ($jurusanList->isEmpty()) {
            $jurusanList = collect(['Rekayasa Perangkat Lunak', 'Desain Komunikasi Visual', 'Teknik Otomasi Industri', 'Teknik Instalasi Tenaga Listrik', 'Teknik Audio Video', 'Teknik Komputer Jaringan']);
        }

        return view('admin.assets.select-jurusan', compact('jurusanList'));
    }

    public function create()
    {
        return view('admin.assets.create');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'code' => 'required|string|max:255|unique:commodities,code',
            'stock' => 'required|integer|min:0',
            'jurusan' => 'required|string',
            'lokasi' => 'required|string',
            'merk' => 'nullable|string|max:255',
            'harga_satuan' => 'nullable|numeric|min:0',
            'sumber' => 'nullable|string|max:255',
            'tahun' => 'nullable|integer',
            'deskripsi' => 'nullable|string',
            'photo' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:10000',
        ]);

        if ($request->hasFile('photo')) {
            $path = $request->file('photo')->store('public/commodities');
            $data['photo'] = $path;
        }

        Commodity::create($data);

        return redirect()->route('admin.assets.index', ['jurusan' => $request->jurusan])
                         ->with('success', 'Barang berhasil ditambahkan.');
    }

    public function edit($id)
    {
        $commodity = Commodity::findOrFail($id);
        return view('admin.assets.edit', compact('commodity'));
    }

    public function update(Request $request, $id)
    {
        $commodity = Commodity::findOrFail($id);

        $data = $request->validate([
            'name' => 'required|string|max:255',
            'code' => 'required|string|max:255|unique:commodities,code,' . $commodity->id,
            'stock' => 'required|integer|min:0',
            'jurusan' => 'required|string',
            'lokasi' => 'required|string',
            'merk' => 'nullable|string|max:255',
            'harga_satuan' => 'nullable|numeric|min:0',
            'sumber' => 'nullable|string|max:255',
            'tahun' => 'nullable|integer',
            'deskripsi' => 'nullable|string',
            'photo' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:10000',
        ]);

        if ($request->hasFile('photo')) {
            // Delete old photo if it exists
            if ($commodity->photo) {
                Storage::delete($commodity->photo);
            }

            $path = $request->file('photo')->store('public/commodities');
            $data['photo'] = $path;
        }

        $commodity->update($data);

        return redirect()->route('admin.assets.index', ['jurusan' => $request->jurusan])
                         ->with('success', 'Barang berhasil diperbarui.');
    }

    public function destroy($id)
    {
        try {
            $commodity = Commodity::findOrFail($id);
            $commodity->delete();
            return redirect()->back()->with('success', 'Barang berhasil dihapus.');
        } catch (\Exception $e) {
            return redirect()->back()->with('error', 'Gagal menghapus barang: ' . $e->getMessage());
        }
    }

    public function detail($id)
    {
        try {
            $commodity = Commodity::findOrFail($id);
            return response()->json($commodity);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json(['error' => 'Aset tidak ditemukan.'], 404);
        }
    }
}