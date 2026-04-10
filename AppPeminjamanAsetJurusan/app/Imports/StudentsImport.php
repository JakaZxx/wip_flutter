<?php

namespace App\Imports;

use App\Models\User;
use App\Models\Student;
use Illuminate\Support\Facades\Hash;
use Maatwebsite\Excel\Concerns\ToModel;
use Maatwebsite\Excel\Concerns\WithHeadingRow;
use Maatwebsite\Excel\Concerns\WithValidation;
use Maatwebsite\Excel\Concerns\WithChunkReading;

class StudentsImport implements ToModel, WithHeadingRow, WithValidation, WithChunkReading
{
    private $schoolClassId;

    public function __construct($schoolClassId)
    {
        $this->schoolClassId = $schoolClassId;
    }

    public function model(array $row)
    {
        // Check if student user exists by email
        $existingUser = User::where('email', $row['email'])->first();
        if ($existingUser) {
            return null; // Skip if user exists
        }

        // Create user for student
        $user = User::create([
            'name' => $row['nama'],
            'email' => $row['email'],
            'role' => 'students',
            'password' => Hash::make('smkn4bdg'), // Default password as specified
            'approval_status' => 'approved',
        ]);

        // Create student record
        Student::create([
            'name' => $row['nama'],
            'school_class_id' => $this->schoolClassId,
            'user_id' => $user->id,
        ]);

        return $user;
    }

    public function rules(): array
    {
        return [
            'nama' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
        ];
    }

    public function chunkSize(): int
    {
        return 1000;
    }
}
