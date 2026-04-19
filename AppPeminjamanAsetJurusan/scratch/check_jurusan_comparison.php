<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require_once __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$coms = App\Models\Commodity::all();
echo "Commodity Jurusan raw vs accessor:\n";
foreach ($coms as $c) {
    echo "  [" . $c->id . "] " . $c->name . " | raw: '" . $c->getRawOriginal('jurusan') . "' | accessor: '" . $c->jurusan . "'\n";
}

$officers = App\Models\User::where('role', 'officers')->get();
echo "\nOfficer Jurusan raw vs accessor:\n";
foreach ($officers as $u) {
    echo "  " . $u->email . " | raw: '" . $u->getRawOriginal('jurusan') . "' | accessor: '" . $u->jurusan . "'\n";
}

// Test the query that the PeminjamanController uses for officer TKJ
$officerTkj = App\Models\User::where('email', 'officer.tkj@smkn4bdg.sch.id')->first();
if ($officerTkj) {
    echo "\nTest: Borrowings that officer.tkj would see (jurusan='" . $officerTkj->jurusan . "'):\n";
    $borrowings = App\Models\Borrowing::with('student.user', 'student.schoolClass', 'items.commodity')
        ->whereHas('items.commodity', function($q) use ($officerTkj) {
            $q->where('jurusan', $officerTkj->jurusan)
              ->orWhereNull('jurusan')
              ->orWhere('jurusan', 'Semua');
        })
        ->get();
    echo "  Found " . $borrowings->count() . " borrowings\n";
}
