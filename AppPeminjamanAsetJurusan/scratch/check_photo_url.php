<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require_once __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$b = App\Models\Borrowing::first();
foreach ($b->items as $i) {
    echo $i->commodity->name . ": " . $i->commodity->photo_url . "\n";
}
