<?php

namespace App\Imports;

use App\Models\User;
use App\Models\Student;
use App\Models\SchoolClass;
use Illuminate\Support\Facades\Hash;
use Maatwebsite\Excel\Concerns\ToModel;
use Maatwebsite\Excel\Concerns\WithHeadingRow;
use Maatwebsite\Excel\Concerns\WithValidation;
use Maatwebsite\Excel\Concerns\WithChunkReading;

class ClassesStudentsImport implements ToModel, WithHeadingRow, WithValidation, WithChunkReading
{
    public function model(array $row)
    {
        // Check if class exists, if not create it
        $schoolClass = SchoolClass::where('name', $row['nama_kelas'])->first();

        if (!$schoolClass) {
            $schoolClass = SchoolClass::create([
                'name' => $row['nama_kelas'],
                'level' => $row['level'] ?? 'X', // Use provided level or default to 'X'
                'program_study' => 'Umum', // Default
                'capacity' => 30, // Default
            ]);
        }

        // Check if student user exists
        $existingUser = User::where('nis', $row['nis'])->first();

        if (!$existingUser) {
            // Create user for student
            $user = User::create([
                'name' => $row['nama_siswa'],
                'email' => $row['email_siswa'],
                'nis' => $row['nis'],
                'role' => 'students',
                'password' => Hash::make('password123'), // Default password
                'approval_status' => 'approved',
            ]);

            // Create student record
            Student::create([
                'name' => $row['nama_siswa'],
                'school_class_id' => $schoolClass->id,
                'user_id' => $user->id,
            ]);

            return $user;
        }

        return null; // Skip if student already exists
    }

    public function rules(): array
    {
        return [
            'nama_kelas' => 'required|string|max:255',
            'wali_kelas' => 'nullable|string|max:255',
            'nis' => 'required|numeric|unique:users,nis',
            'nama_siswa' => 'required|string|max:255',
            'email_siswa' => 'required|email|unique:users,email',
        ];
    }

    public function chunkSize(): int
    {
        return 1000;
    }
}
