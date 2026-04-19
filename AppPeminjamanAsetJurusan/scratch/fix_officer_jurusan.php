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
    'RPL' => 'Rekayasa Perangkat Lunak',
    'DKV' => 'Desain Komunikasi Visual',
    'TKJ' => 'Teknik Komputer Jaringan',
    'TOI' => 'Teknik Otomasi Industri',
    'TITL' => 'Teknik Instalasi Tenaga Listrik',
    'TAV' => 'Teknik Audio Video'
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
    
    echo "  Officer updated: " . $officerEmail . " with jurusan " . $nama . "\n";
}

echo "Updating Jurusan completed successfully.\n";
