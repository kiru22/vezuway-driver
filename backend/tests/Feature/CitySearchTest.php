<?php

namespace Tests\Feature;

use App\Models\User;
use App\Modules\Cities\Models\City;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CitySearchTest extends TestCase
{
    use RefreshDatabase;

    private User $user;

    protected function setUp(): void
    {
        parent::setUp();
        $this->user = User::factory()->create();
    }

    public function test_search_returns_matching_results(): void
    {
        City::factory()->withName('Madrid', 'Madrid', 'Мадрид')->country('ES')->create();
        City::factory()->withName('Barcelona', 'Barcelona', 'Барселона')->country('ES')->create();
        City::factory()->withName('Malaga', 'Málaga', 'Малага')->country('ES')->create();

        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/cities/search?q=Madrid');

        $response->assertOk();
        $response->assertJsonCount(1, 'data');
        $response->assertJsonPath('data.0.name', 'Madrid');
    }

    public function test_search_filters_by_country(): void
    {
        City::factory()->withName('Valencia')->country('ES')->create();
        City::factory()->withName('Kyiv', 'Kiev', 'Київ')->country('UA')->create();

        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/cities/search?q=Val&countries=ES');

        $response->assertOk();
        $response->assertJsonCount(1, 'data');
        $response->assertJsonPath('data.0.country_code', 'ES');
    }

    public function test_search_with_cyrillic(): void
    {
        City::factory()->withName('Kyiv', 'Kiev', 'Київ')->country('UA')->create();

        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/cities/search?q=Київ');

        $response->assertOk();
        $response->assertJsonCount(1, 'data');
        $response->assertJsonPath('data.0.name', 'Kyiv');
    }

    public function test_empty_query_returns_empty(): void
    {
        City::factory()->count(5)->create();

        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/cities/search?q=');

        $response->assertOk();
        $response->assertJsonCount(0, 'data');
    }

    public function test_results_ordered_by_population(): void
    {
        City::factory()->withName('Madrid')->country('ES')->population(3200000)->create();
        City::factory()->withName('Malaga')->country('ES')->population(570000)->create();
        City::factory()->withName('Marbella')->country('ES')->population(140000)->create();

        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/cities/search?q=Ma&countries=ES');

        $response->assertOk();
        $names = collect($response->json('data'))->pluck('name')->toArray();
        $this->assertEquals(['Madrid', 'Malaga', 'Marbella'], $names);
    }

    public function test_limit_is_respected(): void
    {
        City::factory()->count(30)->country('ES')->create();

        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/cities/search?q=ci&limit=5');

        $response->assertOk();
        $this->assertLessThanOrEqual(5, count($response->json('data')));
    }

    public function test_requires_authentication(): void
    {
        $response = $this->getJson('/api/v1/cities/search?q=Madrid');

        $response->assertUnauthorized();
    }

    public function test_search_returns_expected_fields(): void
    {
        City::factory()->withName('Madrid', 'Madrid', 'Мадрид')->country('ES')->create();

        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/cities/search?q=Madrid');

        $response->assertOk();
        $response->assertJsonStructure([
            'data' => [
                '*' => [
                    'id',
                    'name',
                    'name_local',
                    'name_es',
                    'name_uk',
                    'country_code',
                    'admin1_name',
                    'population',
                    'latitude',
                    'longitude',
                ],
            ],
        ]);
    }

    public function test_search_with_multiple_countries(): void
    {
        City::factory()->withName('Madrid')->country('ES')->create();
        City::factory()->withName('Kyiv', 'Kiev', 'Київ')->country('UA')->create();
        City::factory()->withName('Berlin', 'Berlin', 'Берлін')->country('DE')->create();

        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/cities/search?q=Ma&countries=ES,DE');

        $response->assertOk();
        $countryCodes = collect($response->json('data'))->pluck('country_code')->unique()->toArray();
        foreach ($countryCodes as $code) {
            $this->assertContains($code, ['ES', 'DE']);
        }
    }

    public function test_search_finds_by_spanish_name(): void
    {
        City::factory()->withName('Kyiv', 'Kiev', 'Київ')->country('UA')->create();

        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/cities/search?q=Kiev');

        $response->assertOk();
        $response->assertJsonCount(1, 'data');
        $response->assertJsonPath('data.0.name', 'Kyiv');
    }
}
