<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require_once __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);

$user = App\Models\User::first();
$hash = sha1($user->getEmailForVerification());
$id = $user->id;

$request = Illuminate\Http\Request::create("/api/email/verify/{$id}/{$hash}", 'GET');
$response = $kernel->handle($request);

echo "Status: " . $response->getStatusCode() . "\n";
echo "Content: " . $response->getContent() . "\n";
