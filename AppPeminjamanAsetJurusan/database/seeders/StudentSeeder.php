<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\User;
use App\Models\Student;
use App\Models\SchoolClass;

class StudentSeeder extends Seeder
{
    public function run()
    {
        $class = SchoolClass::first();
        if (!$class) {
            $class = SchoolClass::create([
                'name' => 'X TKJ 1',
                'level' => '10',
                'program_study' => 'TKJ',
            ]);
        }

        $user = User::updateOrCreate(
            ['email' => 'siswa@aset.com'],
            [
                'name' => 'Siswa Test',
                'password' => Hash::make('siswa123'),
                'role' => 'students',
                'approval_status' => 'approved',
                'email_verified_at' => now(),
            ]
        );

        Student::updateOrCreate(
            ['user_id' => $user->id],
            [
                'name' => 'Siswa Test',
                'school_class_id' => $class->id,
            ]
        );
    }
}
