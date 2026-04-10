<?php

use App\Models\User;
use App\Models\Commodity;
use Illuminate\Support\Facades\Auth;

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';

$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$user = User::find(1); // Change to your logged-in user ID or use Auth::user() if running in web context
echo "User jurusan: " . $user->jurusan . PHP_EOL;

$commoditiesJurusan = Commodity::select('jurusan')->distinct()->get()->pluck('jurusan')->toArray();
echo "Distinct jurusan in commodities:" . PHP_EOL;
foreach ($commoditiesJurusan as $jurusan) {
    echo "- " . $jurusan . PHP_EOL;
}
