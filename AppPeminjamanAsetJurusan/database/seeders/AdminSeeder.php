<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Schema;
use App\Models\User;

class AdminSeeder extends Seeder
{
    public function run()
    {
        // Pastikan tabel 'users' sudah ada sebelum dijalankan
        if (!Schema::hasTable('users')) {
            $this->command->warn('Tabel users belum ada. Jalankan: php artisan migrate');
            return;
        }

        try {
            User::updateOrCreate(
                ['email' => 'admin@aset.com'],
                [
                    'name' => 'Admin Aset',
                    'password' => Hash::make('admin123'),
                    'role' => 'admin',
                    'approval_status' => 'approved',
                ]
            );

            User::updateOrCreate(
                ['email' => 'ilham@aset.com'],
                [
                    'name' => 'Admin Kedua',
                    'password' => Hash::make('ilham123'),
                    'role' => 'admin',
                    'approval_status' => 'approved',
                ]
            );

            $this->command->info('AdminSeeder berhasil dijalankan.');
        } catch (\Exception $e) {
            $this->command->error('Gagal menjalankan seeder: ' . $e->getMessage());
        }
    }
}
