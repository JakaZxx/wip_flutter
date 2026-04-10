<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class OfficerSeeder extends Seeder
{
    public function run()
    {
        User::updateOrCreate(
            ['email' => 'officer@aset.com'],
            [
                'name' => 'Petugas TKJ',
                'password' => Hash::make('officer123'),
                'role' => 'officers',
                'jurusan' => 'tkj',
                'approval_status' => 'approved',
            ]
        );

        User::updateOrCreate(
            ['email' => 'dkv@aset.com'],
            [
                'name' => 'Petugas DKV',
                'password' => Hash::make('dkv123'),
                'role' => 'officers',
                'jurusan' => 'dkv',
                'approval_status' => 'approved',
            ]
        );
    }
}
