<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Student;

class FixStudentRecordsSeeder extends Seeder
{
    public function run()
    {
        // Get all users with role 'students' that don't have a student record
        $usersWithoutStudents = User::where('role', 'students')
            ->whereDoesntHave('student')
            ->get();

        foreach ($usersWithoutStudents as $user) {
            Student::create([
                'name' => $user->name,
                'user_id' => $user->id,
                'school_class_id' => null, // Can be set later if needed
            ]);
        }

        $this->command->info('Created ' . $usersWithoutStudents->count() . ' missing student records.');
    }
}
