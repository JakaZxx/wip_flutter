<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require_once __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== Normalizing commodity jurusan to lowercase ===\n";
$updated = DB::table('commodities')->update([
    'jurusan' => DB::raw('LOWER(TRIM(jurusan))')
]);
echo "Updated $updated commodity records\n";

echo "\n=== Normalizing user jurusan to lowercase ===\n";
$updated = DB::table('users')->whereNotNull('jurusan')->update([
    'jurusan' => DB::raw('LOWER(TRIM(jurusan))')
]);
echo "Updated $updated user records\n";

// Show results
$coms = DB::table('commodities')->get(['id','name','jurusan']);
echo "\nCommodities after normalization:\n";
foreach ($coms as $c) {
    echo "  [{$c->id}] {$c->name} | jurusan: '{$c->jurusan}'\n";
}

$officers = DB::table('users')->where('role','officers')->get(['email','jurusan']);
echo "\nOfficers after normalization:\n";
foreach ($officers as $u) {
    echo "  {$u->email} | jurusan: '{$u->jurusan}'\n";
}

echo "\nDone! All jurusans are now lowercase for consistent querying.\n";
