<?php

require_once 'vendor/autoload.php';

$app = require_once 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\Commodity;
use App\Models\User;
use Illuminate\Support\Facades\Auth;

// Test 1: Check if commodities exist
echo "=== TEST 1: Commodities Count ===\n";
echo "Total commodities: " . Commodity::count() . "\n";
echo "Sample commodities:\n";
$commodities = Commodity::take(3)->get();
foreach ($commodities as $commodity) {
    echo "- {$commodity->name} (Stock: {$commodity->stock}, Jurusan: {$commodity->jurusan})\n";
}

echo "\n=== TEST 2: Jurusan List ===\n";
$jurusanList = Commodity::select('jurusan')->distinct()->pluck('jurusan');
echo "Jurusan count: " . $jurusanList->count() . "\n";
foreach ($jurusanList as $jurusan) {
    echo "- {$jurusan}\n";
}

echo "\n=== TEST 3: Query with filters ===\n";
$search = '';
$jurusan = '';

// Simulate the controller query
$query = Commodity::query();

if (!empty($search)) {
    $query->where(function($q) use ($search) {
        $q->where('name', 'like', "%{$search}%")
          ->orWhere('code', 'like', "%{$search}%");
    });
}

if (!empty($jurusan)) {
    $query->where('jurusan', $jurusan);
}

$assets = $query->orderBy('name', 'asc')->paginate(12);
echo "Assets count: " . $assets->count() . "\n";
echo "Total assets: " . $assets->total() . "\n";

foreach ($assets as $asset) {
    echo "- {$asset->name} (Stock: {$asset->stock})\n";
}

echo "\n=== TEST 4: Check if assets have stock > 0 ===\n";
$assetsWithStock = Commodity::where('stock', '>', 0)->count();
echo "Assets with stock > 0: " . $assetsWithStock . "\n";

echo "\n=== TEST 5: Check specific jurusan ===\n";
$assetsByJurusan = Commodity::where('jurusan', 'Rekayasa Perangkat Lunak')->count();
echo "Assets in RPL: " . $assetsByJurusan . "\n";
