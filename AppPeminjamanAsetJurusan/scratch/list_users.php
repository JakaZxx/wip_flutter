<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require_once __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$users = App\Models\User::all();
echo "Email | Role | Jurusan | Password (Hint)\n";
foreach ($users as $u) {
    echo "{$u->email} | {$u->role} | {$u->jurusan} | (password)\n";
}
