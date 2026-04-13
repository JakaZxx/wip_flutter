<?php

require_once __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';

$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\Commodity;

echo "Testing Commodities Jurusan Data\n";
echo "=================================\n";

// Check all commodities with jurusan
$commodities = Commodity::all();
echo "Total commodities: " . $commodities->count() . "\n\n";

$jurusans = $commodities->pluck('jurusan')->unique()->filter();
echo "Available jurusan in commodities: " . $jurusans->join(', ') . "\n\n";

foreach($jurusans as $jurusan) {
    $count = $commodities->where('jurusan', $jurusan)->count();
    echo "Jurusan '" . $jurusan . "': " . $count . " items\n";
    $items = $commodities->where('jurusan', $jurusan)->take(3); // Show first 3 items
    foreach($items as $item) {
        echo "  - " . $item->name . " (Stock: " . $item->stock . ")\n";
    }
    echo "\n";
}

echo "Test completed.\n";
