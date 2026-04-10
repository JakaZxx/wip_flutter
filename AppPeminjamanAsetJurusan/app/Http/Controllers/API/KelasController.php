<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller; // Mengimpor Controller dasar
use App\Models\SchoolClass; // Mengimpor model SchoolClass
use Illuminate\Http\Request; // Mengimpor Request
use Illuminate\Support\Facades\Validator; // Mengimpor Validator
use Illuminate\Support\Facades\Log;

class KelasController extends Controller
{
    /**
     * Menampilkan semua data kelas.
     * Metode ini untuk endpoint GET /api/school-classes.
     */
    public function index()
    {
        Log::info('KelasController::index started');
        try {
            // Mengambil semua kelas dengan relasi students
            $classes = SchoolClass::with('students')->get();

            Log::info('KelasController::index ended');
            return response()->json([
                'success' => true,
                'message' => 'Data kelas berhasil diambil',
                'data' => $classes
            ]);
        } catch (\Exception $e) {
            Log::error('KelasController::index error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while fetching classes'
            ], 500);
        }
    }

    /**
     * Menambahkan kelas baru (opsional, jika diperlukan).
     * Metode ini bisa ditambahkan jika route POST ada.
     */
    public function store(Request $request)
    {
        Log::info('KelasController::store started');
        try {
            // Validasi input
            $validator = Validator::make($request->all(), [
                'name' => 'required|string|max:255',
                'level' => 'nullable|string|max:255',
                'program_study' => 'nullable|string|max:255',
                'capacity' => 'nullable|integer|min:0',
                'description' => 'nullable|string'
            ]);

            if ($validator->fails()) {
                Log::warning('KelasController::store validation failed', ['errors' => $validator->errors()]);
                Log::info('KelasController::store ended');
                return response()->json([
                    'success' => false,
                    'message' => 'Validasi gagal: ' . $validator->errors()->first(),
                    'data' => null
                ], 400);
            }

            // Buat kelas baru
            $class = SchoolClass::create($request->all());

            Log::info('KelasController::store ended');
            return response()->json([
                'success' => true,
                'message' => 'Kelas berhasil ditambahkan',
                'data' => $class
            ], 201);
        } catch (\Exception $e) {
            Log::error('KelasController::store error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while creating class'
            ], 500);
        }
    }

    /**
     * Memperbarui data kelas berdasarkan ID.
     * Metode ini untuk endpoint PUT /api/school-classes/{id}.
     */
    public function update(Request $request, $id)
    {
        Log::info('KelasController::update started');
        try {
            // Cari kelas berdasarkan ID
            $class = SchoolClass::find($id);

            if (!$class) {
                Log::info('KelasController::update ended');
                return response()->json([
                    'success' => false,
                    'message' => 'Kelas tidak ditemukan',
                    'data' => null
                ], 404);
            }

            // Validasi input
            $validator = Validator::make($request->all(), [
                'name' => 'required|string|max:255',
                'level' => 'nullable|string|max:255',
                'program_study' => 'nullable|string|max:255',
                'capacity' => 'nullable|integer|min:0',
                'description' => 'nullable|string'
            ]);

            if ($validator->fails()) {
                Log::warning('KelasController::update validation failed', ['errors' => $validator->errors()]);
                Log::info('KelasController::update ended');
                return response()->json([
                    'success' => false,
                    'message' => 'Validasi gagal: ' . $validator->errors()->first(),
                    'data' => null
                ], 400);
            }

            // Update kelas
            $class->update($request->all());

            Log::info('KelasController::update ended');
            return response()->json([
                'success' => true,
                'message' => 'Kelas berhasil diperbarui',
                'data' => $class
            ]);
        } catch (\Exception $e) {
            Log::error('KelasController::update error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while updating class'
            ], 500);
        }
    }

    /**
     * Menghapus kelas berdasarkan ID.
     * Metode ini untuk endpoint DELETE /api/school-classes/{id}.
     */
    public function destroy($id)
    {
        Log::info('KelasController::destroy started');
        try {
            // Cari kelas berdasarkan ID
            $class = SchoolClass::find($id);

            if (!$class) {
                Log::info('KelasController::destroy ended');
                return response()->json([
                    'success' => false,
                    'message' => 'Kelas tidak ditemukan',
                    'data' => null
                ], 404);
            }

            // Hapus kelas
            $class->delete();

            Log::info('KelasController::destroy ended');
            return response()->json([
                'success' => true,
                'message' => 'Kelas berhasil dihapus',
                'data' => null
            ]);
        } catch (\Exception $e) {
            Log::error('KelasController::destroy error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while deleting class'
            ], 500);
        }
    }
}
