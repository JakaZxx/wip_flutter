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

class UsersImport implements ToModel, WithHeadingRow, WithValidation, WithChunkReading
{
    public function model(array $row)
    {
        // Check if user already exists
        $existingUser = User::where('email', $row['email'])->first();
        if ($existingUser) {
            return null; // Skip if user exists
        }

        // Create user
        $user = User::create([
            'name' => $row['nama'],
            'email' => $row['email'],
            'nis' => $row['nis'] ?? null,
            'role' => $row['role'] ?? 'students',
            'password' => Hash::make($row['password'] ?? 'password123'),
            'approval_status' => ($row['role'] ?? 'students') === 'officers' ? 'pending' : 'approved',
        ]);

        // If student, create student record and link to class
        if (($row['role'] ?? 'students') === 'students') {
            $schoolClass = SchoolClass::where('name', $row['nama_kelas'])->first();

            if (!$schoolClass) {
                // Create class if doesn't exist
                $schoolClass = SchoolClass::create([
                    'name' => $row['nama_kelas'],
                    'level' => 'SMA', // Default
                    'program_study' => 'Umum', // Default
                    'capacity' => 30, // Default
                ]);
            }

            Student::create([
                'name' => $row['nama'],
                'school_class_id' => $schoolClass->id,
                'user_id' => $user->id,
            ]);
        }

        return $user;
    }

    public function rules(): array
    {
        return [
            'nama' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'nis' => 'nullable|numeric|unique:users,nis',
            'role' => 'nullable|in:students,officers',
            'nama_kelas' => 'required_if:role,students|string|max:255',
        ];
    }

    public function chunkSize(): int
    {
        return 1000;
    }
}
