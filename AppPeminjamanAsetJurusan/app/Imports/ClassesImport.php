<?php

namespace App\Imports;

use App\Models\SchoolClass;
use Maatwebsite\Excel\Concerns\ToModel;
use Maatwebsite\Excel\Concerns\WithHeadingRow;
use Maatwebsite\Excel\Concerns\WithValidation;
use Maatwebsite\Excel\Concerns\WithChunkReading;

class ClassesImport implements ToModel, WithHeadingRow, WithValidation, WithChunkReading
{
    public function model(array $row)
    {
        // Check if class already exists by name
        $existingClass = SchoolClass::where('name', $row['nama_kelas'])->first();
        if ($existingClass) {
            return null; // Skip if class exists
        }

        return new SchoolClass([
            'name' => $row['nama_kelas'],
            'level' => $row['tingkat'],
            'program_study' => $row['program_studi'],
            'capacity' => $row['kapasitas'],
        ]);
    }

    public function rules(): array
    {
        return [
            'nama_kelas' => 'required|string|max:255|unique:school_classes,name',
            'tingkat' => 'required|in:X,XI,XII',
            'program_studi' => 'required|string|max:255',
            'kapasitas' => 'required|integer|min:1|max:50',
        ];
    }

    public function chunkSize(): int
    {
        return 1000;
    }
}
