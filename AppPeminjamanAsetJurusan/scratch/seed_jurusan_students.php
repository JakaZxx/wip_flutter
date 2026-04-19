<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require_once __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use App\Models\Student;
use App\Models\SchoolClass;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

$jurusans = [
    'RPL' => 'Rekayasa Perangkat Lunak (RPL)',
    'DKV' => 'Desain Komunikasi Visual (DKV)',
    'TKJ' => 'Teknik Komputer Jaringan (TKJ)',
    'TOI' => 'Teknik Otomasi Industri (TOI)',
    'TITL' => 'Teknik Instalasi Tenaga Listrik (TITL)',
    'TAV' => 'Teknik Audio Video (TAV)'
];

$password = Hash::make('password123');

foreach ($jurusans as $kode => $nama) {
    echo "Processing $kode...\n";
    
    // Create Officer if not exists
    $officerEmail = "officer." . strtolower($kode) . "@smkn4bdg.sch.id";
    $officer = User::firstOrCreate(
        ['email' => $officerEmail],
        [
            'name' => "Petugas $kode",
            'role' => 'officers',
            'jurusan' => $nama,
            'password' => $password,
            'approval_status' => 'approved',
            'email_verified_at' => now(),
        ]
    );

    // Update officer if it already existed
    $officer->jurusan = $nama;
    $officer->save();
    
    echo "  Officer created/updated: " . $officerEmail . "\n";

    // Create 10 Students for this Jurusan
    for ($i = 1; $i <= 10; $i++) {
        // Distribute classes: XII, XI, X and 1, 2, 3
        $tingkat = ['X', 'XI', 'XII'][$i % 3];
        $nomor = ($i % 3) + 1; // 1, 2, 3
        $className = "$tingkat $kode $nomor";
        
        $schoolClass = SchoolClass::firstOrCreate(
            ['name' => $className],
            [
                'level' => $tingkat,
                'program_study' => $kode,
                'capacity' => 36,
                'description' => "Kelas $className Auto-Generated",
            ]
        );

        $studentPadded = str_pad($i, 3, '0', STR_PAD_LEFT);
        $studentEmail = "student." . strtolower($kode) . $studentPadded . "@smkn4bdg.sch.id";
        $studentName = "Siswa $kode $i";
        
        $user = User::firstOrCreate(
            ['email' => $studentEmail],
            [
                'name' => $studentName,
                'role' => 'students',
                'password' => $password,
                'approval_status' => 'approved',
                'email_verified_at' => now(),
            ]
        );
        
        // Ensure student record exists
        Student::updateOrCreate(
            ['user_id' => $user->id],
            [
                'name' => $studentName,
                'school_class_id' => $schoolClass->id,
            ]
        );
    }
    echo "  10 Students populated for $kode.\n";
}

echo "Seeding completed successfully.\n";
