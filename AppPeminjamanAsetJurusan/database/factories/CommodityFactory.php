<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use App\Models\Commodity;

class CommodityFactory extends Factory
{
    protected $model = Commodity::class;

    public function definition()
    {
        return [
            'name' => $this->faker->word,
            'stock' => $this->faker->numberBetween(1, 10),
            'code' => $this->faker->unique()->randomNumber(4),
            'condition' => $this->faker->randomElement(['Baik', 'Rusak Ringan', 'Rusak Berat']),
            'lokasi' => $this->faker->word,
            'jurusan' => $this->faker->word,
        ];
    }
}
