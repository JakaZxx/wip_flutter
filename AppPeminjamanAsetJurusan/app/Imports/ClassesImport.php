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
        $user = auth()->user();
        if ($user && $user->role == 'officers') {
            $userJurusan = strtolower($user->jurusan);
            $rowJurusan = strtolower($row['program_studi']);
            
            $isMatch = str_contains($rowJurusan, $userJurusan);
            if ($userJurusan == 'rpl' && str_contains($rowJurusan, 'rekayasa perangkat lunak')) $isMatch = true;
            if ($userJurusan == 'tkj' && str_contains($rowJurusan, 'teknik komputer jaringan')) $isMatch = true;
            if ($userJurusan == 'dkv' && str_contains($rowJurusan, 'desain komunikasi visual')) $isMatch = true;
            if ($userJurusan == 'toi' && str_contains($rowJurusan, 'teknik otomasi industri')) $isMatch = true;
            if ($userJurusan == 'titl' && str_contains($rowJurusan, 'teknik instalasi tenaga listrik')) $isMatch = true;
            if ($userJurusan == 'tav' && str_contains($rowJurusan, 'teknik audio video')) $isMatch = true;

            if (!$isMatch) {
                return null; // Skip if not matching officer's department
            }
        }

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
