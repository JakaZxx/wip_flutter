<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\SchoolClass;

class SchoolClassSeeder extends Seeder
{
    public function run(): void
    {
        $classes = [
            [
                'name' => 'X DKV 1',
                'level' => 'X',
                'program_study' => 'DKV',
                'capacity' => 36,
                'description' => 'Kelas X Desain Komunikasi Visual 1',
            ],
            [
                'name' => 'XI TKJ 2',
                'level' => 'XI',
                'program_study' => 'TKJ',
                'capacity' => 32,
                'description' => 'Kelas XI Teknik Komputer dan Jaringan 2',
            ],
        ];

        foreach ($classes as $class) {
            SchoolClass::create($class);
        }
    }
}
