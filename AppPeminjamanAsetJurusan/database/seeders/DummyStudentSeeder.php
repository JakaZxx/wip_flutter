<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Student;
use App\Models\SchoolClass;
use Illuminate\Support\Facades\Hash;

class DummyStudentSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        // 1. Create the class
        $schoolClass = SchoolClass::firstOrCreate(
            ['name' => 'XII RPL 3'],
            [
                'program_study' => 'Rekayasa Perangkat Lunak',
                'level' => 'XII',
                'capacity' => 36,
                'description' => 'Kelas XII RPL 3 Dummy'
            ]
        );

        $this->command->info("Class XII RPL 3 created/found.");

        // 2. Create 33 dummy students
        for ($i = 1; $i <= 33; $i++) {
            $name = "Siswa Dummy " . $i;
            $email = "siswa" . $i . "_rpl3@example.com";
            $nis = 'nis' . str_pad($i, 5, '0', STR_PAD_LEFT);
            
            // Check if user already exists
            $user = User::where('email', $email)->orWhere('nis', $nis)->first();
            
            if (!$user) {
                // Create User
                $user = User::create([
                    'name' => $name,
                    'email' => $email,
                    'password' => Hash::make('password123'),
                    'role' => 'students',
                    'jurusan' => 'RPL',
                    'nis' => $nis, // Saved to User table
                    'approval_status' => 'approved',
                    'email_verified_at' => now(), // Auto-verify
                ]);
            }

            // Create Student if not exists
            Student::firstOrCreate(
                ['user_id' => $user->id],
                [
                    'name' => $name,
                    'school_class_id' => $schoolClass->id,
                ]
            );
        }

        $this->command->info("33 dummy students created for XII RPL 3.");
    }
}
