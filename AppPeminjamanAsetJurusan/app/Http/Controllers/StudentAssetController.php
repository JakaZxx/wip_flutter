<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Commodity;
use App\Models\Cart;

class StudentAssetController extends Controller
{
    public function index(Request $request)
    {
        $jurusan = $request->input('jurusan');

        // Redirect to jurusan selection if no jurusan query param
        if (empty($jurusan)) {
            return redirect()->route('students.assets.selectJurusan');
        }

        // Ambil input dari search bar & filter dropdown
        $search = $request->input('search');

        // Query dasar - all data, no default jurusan filter, exclude stock 0
        $query = Commodity::where('stock', '>', 0);

        // Jika ada pencarian (nama atau kode)
        if (!empty($search)) {
            $query->where(function($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('code', 'like', "%{$search}%");
            });
        }

        // Filter by jurusan selected
        if (!empty($jurusan)) {
            $query->where('jurusan', $jurusan);
        }

        // Pagination
        $assets = $query->orderBy('id', 'desc')->paginate(5);

        // Ambil daftar jurusan unik untuk dropdown filter
        $jurusanList = Commodity::select('jurusan')->distinct()->pluck('jurusan');

        // Jika kosong, gunakan daftar default
        if ($jurusanList->isEmpty()) {
            $jurusanList = collect(['Rekayasa Perangkat Lunak', 'Desain Komunikasi Visual', 'Teknik Otomasi Industri', 'Teknik Instalasi Tenaga Listrik', 'Teknik Audio Video', 'Teknik Komputer Jaringan']);
        }

        // Get cart quantities from Cart model
        $cart = Cart::getOrCreateForUser(auth()->id());
        $cartItems = $cart->items()->get();
        $cartQuantities = $cartItems->pluck('quantity', 'commodity_id')->toArray();

        // Get all jurusans for filter dropdown
        $jurusans = Commodity::select('jurusan')->distinct()->pluck('jurusan');
        if ($jurusans->isEmpty()) {
            $jurusans = collect(['Rekayasa Perangkat Lunak', 'Desain Komunikasi Visual', 'Teknik Otomasi Industri', 'Teknik Instalasi Tenaga Listrik', 'Teknik Audio Video', 'Teknik Komputer Jaringan']);
        }

        return view('students.assets.index', compact('assets', 'jurusanList', 'cartQuantities', 'jurusans'));
    }

    public function selectJurusan()
    {
        $jurusanList = Commodity::select('jurusan')->distinct()->pluck('jurusan');

        // Jika kosong, gunakan daftar default
        if ($jurusanList->isEmpty()) {
            $jurusanList = collect(['Rekayasa Perangkat Lunak', 'Desain Komunikasi Visual', 'Teknik Otomasi Industri', 'Teknik Instalasi Tenaga Listrik', 'Teknik Audio Video', 'Teknik Komputer Jaringan']);
        }

        return view('students.assets.select-jurusan', compact('jurusanList'));
    }

    /**
     * Get asset data for AJAX polling
     */
    public function getAssetsData(Request $request)
    {
        $search = $request->input('search');
        $jurusan = $request->input('jurusan');

        $query = Commodity::where('stock', '>', 0);

        if (!empty($search)) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('code', 'like', "%{$search}%");
            });
        }

        if (!empty($jurusan)) {
            $query->where('jurusan', $jurusan);
        }

        $assets = $query->orderBy('id', 'desc')->paginate(5);

        // Get cart quantities
        $cart = Cart::getOrCreateForUser(auth()->id());
        $cartQuantities = $cart->items()->pluck('quantity', 'commodity_id')->toArray();

        return view('students.assets._cards', compact('assets', 'cartQuantities'))->render();
    }
}
