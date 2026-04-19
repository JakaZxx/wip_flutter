<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require_once __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$user = App\Models\User::where('email', 'officer.toi@smkn4bdg.sch.id')->first();
$user->email_verified_at = null;
$user->save();
echo 'http://localhost:8000/api/email/verify/' . $user->id . '/' . sha1($user->getEmailForVerification());
