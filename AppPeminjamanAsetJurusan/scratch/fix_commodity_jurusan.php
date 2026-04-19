<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require_once __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\Commodity;

// Show current distinct jurusans
$jurusans = Commodity::distinct()->pluck('jurusan')->toArray();
echo "Current Jurusans in Commodities:\n";
print_r($jurusans);

// Fix mappings
$mapping = [
    'Tkj' => 'Teknik Komputer Jaringan',
    'tkj' => 'Teknik Komputer Jaringan',
    'TKJ' => 'Teknik Komputer Jaringan',
    'rpl' => 'Rekayasa Perangkat Lunak',
    'RPL' => 'Rekayasa Perangkat Lunak',
    'Ipa' => 'Semua', // Assuming Ipa is invalid, map it to Semua or handle accordingly
];

$updatedCount = 0;
foreach ($mapping as $from => $to) {
    if ($from === 'Ipa') {
        $count = Commodity::where('jurusan', 'Ipa')->update(['jurusan' => 'Semua']);
    } else {
        $count = Commodity::whereRaw("LOWER(jurusan) = ?", [strtolower($from)])->update(['jurusan' => $to]);
    }
    if ($count > 0) {
        echo "Updated $count items from '$from' to '$to'\n";
        $updatedCount += $count;
    }
}

echo "Total updated: $updatedCount\n";

// Show updated distinct jurusans
$jurusans = Commodity::distinct()->pluck('jurusan')->toArray();
echo "Updated Jurusans in Commodities:\n";
print_r($jurusans);
