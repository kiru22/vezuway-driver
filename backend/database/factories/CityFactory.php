<?php

namespace Database\Factories;

use App\Modules\Cities\Models\City;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<City>
 */
class CityFactory extends Factory
{
    protected $model = City::class;

    public function definition(): array
    {
        $name = fake()->city();
        $nameLocal = $name;
        $country = fake()->randomElement(['ES', 'UA', 'PL', 'DE']);

        return [
            'geoname_id' => fake()->unique()->numberBetween(100000, 9999999),
            'name' => $name,
            'name_local' => $nameLocal,
            'name_es' => null,
            'name_uk' => null,
            'country_code' => $country,
            'admin1_name' => fake()->state(),
            'latitude' => fake()->latitude(),
            'longitude' => fake()->longitude(),
            'population' => fake()->numberBetween(100, 5000000),
            'feature_code' => 'PPL',
            'search_text' => City::buildSearchText($name, $nameLocal, null, null),
            'tracking_code' => strtoupper(fake()->unique()->lexify('???')),
        ];
    }

    public function country(string $code): static
    {
        return $this->state(fn () => ['country_code' => $code]);
    }

    public function withName(string $name, ?string $nameEs = null, ?string $nameUk = null): static
    {
        return $this->state(fn () => [
            'name' => $name,
            'name_local' => $name,
            'name_es' => $nameEs,
            'name_uk' => $nameUk,
            'search_text' => City::buildSearchText($name, $name, $nameEs, $nameUk),
        ]);
    }

    public function population(int $population): static
    {
        return $this->state(fn () => ['population' => $population]);
    }
}
