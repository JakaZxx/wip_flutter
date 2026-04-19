<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require_once __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$officers = App\Models\User::where('role', 'officers')->get();
echo "Officers Jurusan list:\n";
foreach ($officers as $u) {
    echo $u->email . " | DB: " . $u->getRawOriginal('jurusan') . " | Accessor: " . $u->jurusan . "\n";
}

$distinctCommodityJurusans = App\Models\Commodity::distinct()->pluck('jurusan');
echo "\nCommodity Jurusan list:\n";
foreach ($distinctCommodityJurusans as $j) {
    echo $j . "\n";
}
