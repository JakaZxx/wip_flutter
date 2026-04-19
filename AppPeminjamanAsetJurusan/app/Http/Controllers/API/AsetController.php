<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller; // Mengimpor Controller dasar Laravel untuk inheritance
use App\Models\Commodity; // Mengimpor model Commodity untuk berinteraksi dengan database
use Illuminate\Http\Request; // Mengimpor Request untuk menangani input dari HTTP request
use Illuminate\Support\Facades\Validator; // Mengimpor Validator untuk validasi input
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage; // Menambahkan impor untuk Storage facade

class AsetController extends Controller
{
    /**
     * Menampilkan detail data aset berdasarkan ID.
     * Metode ini digunakan untuk endpoint GET /api/assets/{id}.
     * Mengembalikan response JSON dengan detail data aset.
     */
    public function show($id)
    {
        Log::info('AsetController::show started');
        try {
            // Mencari aset berdasarkan ID
            $commodity = Commodity::findOrFail($id);

            // Tambahkan photo_url
            $commodity->photo_url = $commodity->photo_url;

            Log::info('AsetController::show ended');
            // Mengembalikan response JSON dengan detail aset
            return response()->json([
                'success' => true,
                'message' => 'Detail aset berhasil diambil',
                'data' => $commodity
            ]);
        } catch (\Exception $e) {
            Log::error('AsetController::show error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            Log::error('AsetController::show ended with error', ['message' => $e->getTraceAsString()]);
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while fetching asset detail'
            ], 500);
        }
    }

    /**
     * Menampilkan semua data aset (commodities).
     * Metode ini digunakan untuk endpoint GET /api/assets.
     * Mengembalikan response JSON dengan semua data aset atau difilter berdasarkan jurusan.
     */
    public function index(Request $request)
    {
        Log::info('AsetController::index started');
        try {
            // Get authenticated user
            $user = auth()->user();

            // If user is an officer, force filter to their jurusan
            if ($user && $user->isOfficer()) {
                $jurusan = $user->jurusan;
            } else {
                // If not officer, use query parameter if provided
                $jurusan = $request->query('jurusan');
            }

            // Apply filtering logic
            $query = Commodity::query();
            if ($jurusan && strtolower($jurusan) !== 'all') {
                $jurusanLower = strtolower($jurusan);
                $query->whereRaw('LOWER(TRIM(jurusan)) = ? OR LOWER(TRIM(jurusan)) = ? OR jurusan IS NULL', [$jurusanLower, 'semua']);
            }
            
            $commodities = $query->get();

            // Tambahkan photo_url untuk setiap commodity
            $commodities = $commodities->map(function ($commodity) {
                $commodity->photo_url = $commodity->photo_url;
                return $commodity;
            });

            Log::info('AsetController::index ended');
            // Mengembalikan response JSON dengan struktur yang diminta
            return response()->json([
                'success' => true,
                'message' => 'Data aset berhasil diambil',
                'data' => $commodities
            ]);
        } catch (\Exception $e) {
            Log::error('AsetController::index error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            Log::error('AsetController::index ended with error', ['message' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while fetching assets'
            ], 500);
        }
    }

    /**
     * Menambahkan data aset baru.
     * Metode ini digunakan untuk endpoint POST /api/assets.
     * Menerima input dari request body dan menyimpannya ke database.
     */
    public function store(Request $request)
    {
        Log::info('AsetController::store started');
        try {
            // Validasi input yang diterima dari request
            // Pastikan field yang diperlukan ada dan sesuai tipe data
            $validator = Validator::make($request->all(), [
                'name' => 'required|string|max:255',
                'code' => 'required|string|max:255|unique:commodities,code',
                'stock' => 'required|integer|min:0',
                'jurusan' => 'required|string|max:255',
                'lokasi' => 'required|string|max:255',
                'condition' => 'nullable|string|max:255',
                'photo' => 'nullable|string|max:255',
                'merk' => 'required|string|max:255',
                'sumber' => 'nullable|string|max:255',
                'tahun' => 'nullable|integer|min:1900|max:' . (date('Y') + 1),
                'deskripsi' => 'nullable|string',
                'harga_satuan' => 'nullable|numeric|min:0'
            ]);

            // If user is an officer, ensure they only add assets for their own jurusan
            $user = auth()->user();
            if ($user && $user->isOfficer()) {
                if (strtolower($request->input('jurusan')) !== strtolower($user->jurusan)) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Unauthorized: Officers can only add assets for their own department (' . strtoupper($user->jurusan) . ').',
                    ], 403);
                }
            }

            // Jika validasi gagal, kembalikan error
            if ($validator->fails()) {
                Log::warning('AsetController::store validation failed', ['errors' => $validator->errors()]);
                Log::info('AsetController::store ended');
                return response()->json([
                    'success' => false, // Operasi gagal
                    'message' => 'Validasi gagal: ' . $validator->errors()->first(), // Pesan error validasi
                    'data' => null // Tidak ada data
                ], 400); // HTTP status 400 Bad Request
            }

            // Membuat instance Commodity baru dengan data dari request
            $commodity = Commodity::create($request->all());

            Log::info('AsetController::store ended');
            // Mengembalikan response sukses dengan data yang baru dibuat
            return response()->json([
                'success' => true,
                'message' => 'Aset berhasil ditambahkan',
                'data' => $commodity
            ], 201); // HTTP status 201 Created
        } catch (\Exception $e) {
            Log::error('AsetController::store error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            Log::error('AsetController::store ended with error', ['message' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while creating asset'
            ], 500);
        }
    }

    /**
     * Mengubah data aset yang sudah ada.
     * Metode ini digunakan untuk endpoint PUT /api/assets/{id}.
     * Menerima ID aset dan data baru dari request body.
     */
    public function update(Request $request, $id)
    {
        Log::info('AsetController::update started');
        try {
            // Mencari aset berdasarkan ID, jika tidak ditemukan throw exception
            $commodity = Commodity::findOrFail($id);

            // If user is an officer, ensure they only update assets from their own jurusan
            $user = auth()->user();
            if ($user && $user->isOfficer()) {
                if (strtolower($commodity->jurusan) !== strtolower($user->jurusan)) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Unauthorized: Officers can only update assets belonging to their own department (' . strtoupper($user->jurusan) . ').',
                    ], 403);
                }
                
                // Also prevent them from changing the jurusan to something else
                if ($request->has('jurusan') && strtolower($request->input('jurusan')) !== strtolower($user->jurusan)) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Unauthorized: Officers cannot change the department of an asset.',
                    ], 403);
                }
            }

            // Validasi input, mirip dengan store tapi code tidak perlu unique karena update
            $validator = Validator::make($request->all(), [
                'name' => 'sometimes|required|string|max:255', // 'sometimes' berarti opsional tapi jika ada wajib
                'code' => 'sometimes|required|string|max:255|unique:commodities,code,' . $id, // Unique kecuali untuk ID ini
                'stock' => 'sometimes|required|integer|min:0',
                'jurusan' => 'nullable|string|max:255',
                'lokasi' => 'nullable|string|max:255',
                'condition' => 'nullable|string|max:255',
                'photo' => 'nullable|string|max:255',
                'merk' => 'nullable|string|max:255',
                'sumber' => 'nullable|string|max:255',
                'tahun' => 'nullable|integer|min:1900|max:' . (date('Y') + 1),
                'deskripsi' => 'nullable|string',
                'harga_satuan' => 'nullable|numeric|min:0'
            ]);

            // Jika validasi gagal
            if ($validator->fails()) {
                Log::warning('AsetController::update validation failed', ['errors' => $validator->errors()]);
                Log::info('AsetController::update ended');
                return response()->json([
                    'success' => false,
                    'message' => 'Validasi gagal: ' . $validator->errors()->first(),
                    'data' => null
                ], 400);
            }

            // Update data aset dengan data dari request
            $commodity->update($request->all());

            Log::info('AsetController::update ended');
            // Mengembalikan response sukses
            return response()->json([
                'success' => true,
                'message' => 'Aset berhasil diubah',
                'data' => $commodity
            ]);
        } catch (\Exception $e) {
            Log::error('AsetController::update error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            Log::error('AsetController::update ended with error', ['message' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while updating asset'
            ], 500);
        }
    }

    /**
     * Menghapus data aset.
     * Metode ini digunakan untuk endpoint DELETE /api/assets/{id}.
     * Menerima ID aset dan menghapusnya dari database.
     */
    public function destroy($id)
    {
        Log::info('AsetController::destroy started');
        try {
            // Mencari aset berdasarkan ID
            $commodity = Commodity::findOrFail($id);

            // If user is an officer, ensure they only delete assets from their own jurusan
            $user = auth()->user();
            if ($user && $user->isOfficer()) {
                if (strtolower($commodity->jurusan) !== strtolower($user->jurusan)) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Unauthorized: Officers can only delete assets belonging to their own department (' . strtoupper($user->jurusan) . ').',
                    ], 403);
                }
            }

            // Menghapus aset
            $commodity->delete();

            Log::info('AsetController::destroy ended');
            // Mengembalikan response sukses
            return response()->json([
                'success' => true,
                'message' => 'Aset berhasil dihapus',
                'data' => null // Tidak ada data karena sudah dihapus
            ]);
        } catch (\Exception $e) {
            Log::error('AsetController::destroy error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            Log::error('AsetController::destroy ended with error', ['message' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while deleting asset'
            ], 500);
        }
    }

    /**
     * Menampilkan semua data aset untuk peminjaman (commodities).
     * Metode ini digunakan untuk endpoint GET /api/commodities.
     * Mengembalikan response JSON dengan semua data aset untuk peminjaman.
     */
    public function commodities(Request $request)
    {
        Log::info('AsetController::commodities started');
        try {
            // Get authenticated user
            $user = auth()->user();

            // If user is an officer, force filter to their jurusan
            if ($user && $user->isOfficer()) {
                $jurusan = $user->jurusan;
            } else {
                // If not officer, use query parameter if provided
                $jurusan = $request->query('jurusan');
            }

            // Apply filtering logic
            $query = Commodity::query();
            if ($jurusan && strtolower($jurusan) !== 'all') {
                $query->where('jurusan', $jurusan);
            }
            
            $commodities = $query->get();

            // Tambahkan photo_url untuk setiap commodity
            $commodities = $commodities->map(function ($commodity) {
                return [
                    'id' => $commodity->id,
                    'name' => $commodity->name,
                    'code' => $commodity->code,
                    'stock' => $commodity->stock,
                    'jurusan' => $commodity->jurusan,
                    'lokasi' => $commodity->lokasi,
                    'condition' => $commodity->condition,
                    'merk' => $commodity->merk,
                    'sumber' => $commodity->sumber,
                    'tahun' => $commodity->tahun,
                    'deskripsi' => $commodity->deskripsi,
                    'harga_satuan' => $commodity->harga_satuan,
                    'photo_url' => $commodity->photo_url,
                ];
            });

            Log::info('AsetController::commodities ended');
            // Mengembalikan response JSON dengan struktur yang diminta
            return response()->json([
                'success' => true,
                'message' => 'Data aset berhasil diambil',
                'data' => $commodities
            ]);
        } catch (\Exception $e) {
            Log::error('AsetController::commodities error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            Log::error('AsetController::commodities ended with error', ['message' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while fetching commodities'
            ], 500);
        }
    }
}
