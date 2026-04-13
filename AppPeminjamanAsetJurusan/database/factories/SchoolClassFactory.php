<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use App\Models\SchoolClass;

class SchoolClassFactory extends Factory
{
    protected $model = SchoolClass::class;

    public function definition()
    {
        return [
            'name' => $this->faker->word,
            'level' => $this->faker->randomElement(['X', 'XI', 'XII']),
            'program_study' => $this->faker->word,
            'capacity' => $this->faker->numberBetween(20, 40),
            'description' => $this->faker->sentence,
        ];
    }
}
