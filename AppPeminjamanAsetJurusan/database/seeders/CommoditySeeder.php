<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Commodity;

class CommoditySeeder extends Seeder
{
    public function run(): void
    {
        $commodities = [
            [
                'name' => 'Laptop ASUS ROG',
                'code' => 'LAB-TKJ-001',
                'stock' => 5,
                'jurusan' => 'TKJ',
                'lokasi' => 'Lab Komputer 1',
                'condition' => 'Baik',
                'merk' => 'Asus',
                'sumber' => 'BOS',
                'tahun' => 2023,
                'deskripsi' => 'Laptop gaming untuk praktek jaringan',
                'harga_satuan' => 15000000,
            ],
            [
                'name' => 'Kamera Canon EOS 200D',
                'code' => 'LAB-DKV-001',
                'stock' => 3,
                'jurusan' => 'DKV',
                'lokasi' => 'Studio DKV',
                'condition' => 'Baik',
                'merk' => 'Canon',
                'sumber' => 'BOS',
                'tahun' => 2022,
                'deskripsi' => 'Kamera DSLR untuk praktek fotografi',
                'harga_satuan' => 8000000,
            ],
            [
                'name' => 'Proyektor Epson',
                'code' => 'SARPRAS-001',
                'stock' => 10,
                'jurusan' => 'SEMUA',
                'lokasi' => 'Gudang Sarpras',
                'condition' => 'Baik',
                'merk' => 'Epson',
                'sumber' => 'BOS',
                'tahun' => 2021,
                'deskripsi' => 'Proyektor untuk presentasi kelas',
                'harga_satuan' => 5000000,
            ],
            [
                'name' => 'Mikroskop Digital',
                'code' => 'LAB-IPA-001',
                'stock' => 2,
                'jurusan' => 'IPA',
                'lokasi' => 'Lab Biologi',
                'condition' => 'Rusak Ringan',
                'merk' => 'Olympus',
                'sumber' => 'BOSP',
                'tahun' => 2020,
                'deskripsi' => 'Mikroskop untuk penelitian sel',
                'harga_satuan' => 12000000,
            ],
        ];

        foreach ($commodities as $commodity) {
            Commodity::create($commodity);
        }
    }
}
