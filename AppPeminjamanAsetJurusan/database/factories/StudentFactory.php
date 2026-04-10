<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use App\Models\Student;
use App\Models\SchoolClass;

class StudentFactory extends Factory
{
    protected $model = Student::class;

    public function definition()
    {
        return [
            'name' => $this->faker->name,
            'school_class_id' => SchoolClass::factory(),
            'user_id' => \App\Models\User::factory(),
        ];
    }
}
