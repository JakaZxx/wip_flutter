<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require_once __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$names = ['Laptop ASUS ROG', 'Harley-Fatboy-RPL'];
$commodities = App\Models\Commodity::whereIn('name', $names)->get();

foreach ($commodities as $c) {
    echo "Name: {$c->name}\n";
    echo "Photo: {$c->photo}\n";
    echo "Photo URL: {$c->photo_url}\n";
    echo "-------------------\n";
}

$u = App\Models\User::where('name', 'LIKE', '%jaka anwar%')->first();
if ($u) {
    echo "User: {$u->name}\n";
    echo "Profile Pic: {$u->profile_picture}\n";
    echo "Profile Pic URL: {$u->profile_picture_url}\n";
}
