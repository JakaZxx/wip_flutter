<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require_once __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

foreach (App\Models\Commodity::all() as $c) {
    echo $c->id . ' - ' . $c->name . " | DB: " . $c->photo . ' | URL: ' . $c->photo_url . "\n";
    if ($c->photo) {
        $path = $c->photo;
        $path = str_replace(['public/', '/storage/', 'storage/'], '', $path);
        $path = ltrim($path, '/');
        $fullPath = storage_path('app/public/' . $path);
        echo "   -> File exists? " . (file_exists($fullPath) ? "YES" : "NO ($fullPath)") . "\n";
    }
}

foreach (App\Models\BorrowingItem::all() as $b) {
    if ($b->return_photo) {
        echo "Return Photo DB: " . $b->return_photo . ' | URL: ' . $b->return_photo_url . "\n";
        $path = $b->return_photo;
        $path = str_replace(['public/', '/storage/', 'storage/'], '', $path);
        $path = ltrim($path, '/');
        $fullPath = storage_path('app/public/' . $path);
        echo "   -> File exists? " . (file_exists($fullPath) ? "YES" : "NO ($fullPath)") . "\n";
    }
}
