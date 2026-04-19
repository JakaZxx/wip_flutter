<?php

use App\Models\User;
use App\Models\Student;
use App\Models\SchoolClass;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;

require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "Starting system repopulation...\n";

// Disable foreign key checks for clean wipe
DB::statement('SET FOREIGN_KEY_CHECKS=0;');

// 1. Preserve Admin, wipe others
$admin = User::where('role', 'admin')->first();
User::where('id', '!=', $admin->id)->delete();
if ($admin) {
    $admin->password = Hash::make('admin123');
    $admin->save();
    echo "Admin password reset to admin123\n";
}

// 2. Wipe Students
Student::truncate();
echo "Students table truncated.\n";

// 3. Ensure Classes exist
$classes = [
    ['name' => 'XII RPL 1', 'level' => 'XII', 'program_study' => 'Rekayasa Perangkat Lunak'],
    ['name' => 'XII TKJ 1', 'level' => 'XII', 'program_study' => 'Teknik Komputer Jaringan'],
    ['name' => 'XII DKV 1', 'level' => 'XII', 'program_study' => 'Desain Komunikasi Visual'],
    ['name' => 'XII TOI 1', 'level' => 'XII', 'program_study' => 'Teknik Otomasi Industri'],
];

$classIds = [];
foreach ($classes as $c) {
    $newClass = SchoolClass::updateOrCreate(['name' => $c['name']], $c);
    $classIds[$c['program_study']] = $newClass->id;
}
echo "Standard classes verified.\n";

// 4. Create Officers
$officers = [
    ['name' => 'Petugas RPL', 'email' => 'rpl@officer.com', 'role' => 'officers'],
    ['name' => 'Petugas TKJ', 'email' => 'tkj@officer.com', 'role' => 'officers'],
    ['name' => 'Petugas DKV', 'email' => 'dkv@officer.com', 'role' => 'officers'],
    ['name' => 'Petugas TOI', 'email' => 'toi@officer.com', 'role' => 'officers'],
];

foreach ($officers as $o) {
    User::create([
        'name' => $o['name'],
        'email' => $o['email'],
        'role' => $o['role'],
        'password' => Hash::make('officer123'),
        'approval_status' => 'approved'
    ]);
}
echo "Officers created with password 'officer123'.\n";

// 5. Create Students
$students = [
    ['name' => 'Siswa RPL 1', 'email' => 'rpl1@student.com', 'nis' => '10001', 'jurusan' => 'Rekayasa Perangkat Lunak'],
    ['name' => 'Siswa TKJ 1', 'email' => 'tkj1@student.com', 'nis' => '20001', 'jurusan' => 'Teknik Komputer Jaringan'],
    ['name' => 'Siswa DKV 1', 'email' => 'dkv1@student.com', 'nis' => '30001', 'jurusan' => 'Desain Komunikasi Visual'],
    ['name' => 'Siswa TOI 1', 'email' => 'toi1@student.com', 'nis' => '40001', 'jurusan' => 'Teknik Otomasi Industri'],
];

foreach ($students as $s) {
    Student::create([
        'name' => $s['name'],
        'email' => $s['email'],
        'nis' => $s['nis'],
        'password' => Hash::make('siswa123'),
        'jurusan' => $s['jurusan'],
        'school_class_id' => $classIds[$s['jurusan']] ?? 1,
        'approval_status' => 'approved'
    ]);
}
echo "Students created with password 'siswa123'.\n";

DB::statement('SET FOREIGN_KEY_CHECKS=1;');
echo "Repopulation complete.\n";
