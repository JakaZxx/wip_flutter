<?php

namespace App\Imports;

use App\Models\Commodity;
use Maatwebsite\Excel\Concerns\ToModel;
use Maatwebsite\Excel\Concerns\WithHeadingRow;
use Maatwebsite\Excel\Concerns\WithValidation;
use Maatwebsite\Excel\Concerns\WithChunkReading;

class AssetsImport implements ToModel, WithHeadingRow, WithValidation, WithChunkReading
{
    public function model(array $row)
    {
        // Check if asset already exists by code
        $existingAsset = Commodity::where('code', (string) $row['kode_barang'])->first();
        if ($existingAsset) {
            return null; // Skip if asset exists
        }

        // Map Indonesian kondisi to English condition values
        $conditionMap = [
            'Baru' => 'good',
            'Baik' => 'good',
            'Cukup' => 'maintenance',
            'Rusak' => 'damaged',
            'Perawatan' => 'maintenance',
        ];

        $condition = $row['kondisi'] ?? 'good';
        $condition = $conditionMap[$condition] ?? 'good';

        return new Commodity([
            'code' => (string) $row['kode_barang'],
            'name' => $row['nama_barang'],
            'merk' => $row['merk'] ?? null,
            'harga_satuan' => isset($row['harga_satuan']) ? (string) $row['harga_satuan'] : null,
            'sumber' => $row['sumber'] ?? null,
            'tahun' => isset($row['tahun']) ? (string) $row['tahun'] : null,
            'deskripsi' => $row['deskripsi'] ?? null,
            'stock' => isset($row['stok']) ? (int) $row['stok'] : 1,
            'condition' => $condition,
            'lokasi' => $row['lokasi'] ?? null,
            'jurusan' => $row['jurusan'] ?? 'Umum',
        ]);
    }

    public function rules(): array
    {
        return [
            'kode_barang' => 'required',
            'nama_barang' => 'required|string|max:255',
            'merk' => 'nullable|string|max:255',
            'harga_satuan' => 'nullable',
            'sumber' => 'nullable|string|max:255',
            'tahun' => 'nullable',
            'deskripsi' => 'nullable|string',
            'stok' => 'nullable|integer',
            'kondisi' => 'nullable|string',
            'lokasi' => 'nullable|string|max:255',
            'jurusan' => 'nullable|string|max:255',
        ];
    }

    public function chunkSize(): int
    {
        return 1000;
    }
}
