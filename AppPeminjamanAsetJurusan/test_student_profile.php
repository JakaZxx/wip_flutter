<?php

require_once __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';

$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\Student;
use App\Models\User;

echo "Testing Student Profile Creation\n";
echo "===============================\n";

// Check if there are any students
$studentCount = Student::count();
echo "Total students: " . $studentCount . "\n";

// Check if there are any users
$userCount = User::count();
echo "Total users: " . $userCount . "\n";

// Check students with user_id
$studentsWithUserId = Student::whereNotNull('user_id')->count();
echo "Students with user_id: " . $studentsWithUserId . "\n";

// List all students with their user_id
$students = Student::all();
foreach ($students as $student) {
    echo "Student: " . $student->name . " | User ID: " . ($student->user_id ?? 'NULL') . "\n";
}

// List all users
$users = User::all();
foreach ($users as $user) {
    echo "User: " . $user->name . " | Role: " . $user->role . "\n";
}

echo "\nTest completed.\n";
