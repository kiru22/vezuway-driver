<?php

namespace Tests\Feature;

use App\Models\User;
use App\Modules\Cities\Models\City;
use App\Modules\Packages\Models\Package;
use App\Modules\Packages\Services\TrackingCodeService;
use App\Modules\Trips\Models\Trip;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TrackingCodeTest extends TestCase
{
    use RefreshDatabase;

    private TrackingCodeService $service;

    protected function setUp(): void
    {
        parent::setUp();
        $this->service = app(TrackingCodeService::class);
        $this->seedCities();
    }

    private function seedCities(): void
    {
        City::factory()->withName('Valencia', 'Valencia', 'Валенсія')
            ->country('ES')->population(800000)
            ->create(['tracking_code' => 'VLC']);

        City::factory()->withName('Madrid', 'Madrid', 'Мадрид')
            ->country('ES')->population(3300000)
            ->create(['tracking_code' => 'MAD']);

        City::factory()->withName('Kyiv', 'Київ', 'Київ')
            ->country('UA')->population(2900000)
            ->create(['tracking_code' => 'IEV', 'name_local' => 'Київ']);

        City::factory()->withName('Kharkiv', 'Харків', 'Харків')
            ->country('UA')->population(1400000)
            ->create(['tracking_code' => 'HRK', 'name_local' => 'Харків']);

        City::factory()->withName('Lviv', 'Львів', 'Львів')
            ->country('UA')->population(720000)
            ->create(['tracking_code' => 'LWO', 'name_local' => 'Львів', 'name_es' => 'Leópolis']);

        City::factory()->withName('Odesa', 'Одеса', 'Одеса')
            ->country('UA')->population(1000000)
            ->create(['tracking_code' => 'ODS', 'name_local' => 'Одеса']);
    }

    public function test_resolve_city_code_from_canonical_name(): void
    {
        $this->assertEquals('VLC', $this->service->resolveCityCode('Valencia'));
        $this->assertEquals('IEV', $this->service->resolveCityCode('Kyiv'));
        $this->assertEquals('MAD', $this->service->resolveCityCode('Madrid'));
    }

    public function test_resolve_city_code_is_case_insensitive(): void
    {
        $this->assertEquals('VLC', $this->service->resolveCityCode('VALENCIA'));
        $this->assertEquals('VLC', $this->service->resolveCityCode('valencia'));
        $this->assertEquals('IEV', $this->service->resolveCityCode('KYIV'));
    }

    public function test_resolve_city_code_from_spanish_name(): void
    {
        $this->assertEquals('LWO', $this->service->resolveCityCode('Leópolis'));
    }

    public function test_resolve_city_code_from_ukrainian_name(): void
    {
        $this->assertEquals('IEV', $this->service->resolveCityCode('Київ'));
        $this->assertEquals('LWO', $this->service->resolveCityCode('Львів'));
        $this->assertEquals('ODS', $this->service->resolveCityCode('Одеса'));
        $this->assertEquals('VLC', $this->service->resolveCityCode('Валенсія'));
    }

    public function test_resolve_city_code_returns_null_for_unknown(): void
    {
        $this->assertNull($this->service->resolveCityCode('UnknownCity'));
        $this->assertNull($this->service->resolveCityCode(null));
        $this->assertNull($this->service->resolveCityCode(''));
    }

    public function test_generate_tracking_code_with_city(): void
    {
        $code = $this->service->generate('Valencia', null);

        $this->assertMatchesRegularExpression('/^VLC-\d{4}-\d{2,3}$/', $code);
        $dateStr = now()->format('md');
        $this->assertStringContainsString("-{$dateStr}-", $code);
        $this->assertStringEndsWith('-01', $code);
    }

    public function test_generate_sequential_codes_same_city_date(): void
    {
        $code1 = $this->service->generate('Valencia', null);
        $this->createPackageWithCode($code1);

        $code2 = $this->service->generate('Valencia', null);
        $this->createPackageWithCode($code2);

        $code3 = $this->service->generate('Valencia', null);

        $dateStr = now()->format('md');
        $this->assertEquals("VLC-{$dateStr}-01", $code1);
        $this->assertEquals("VLC-{$dateStr}-02", $code2);
        $this->assertEquals("VLC-{$dateStr}-03", $code3);
    }

    public function test_generate_fallback_code_without_city(): void
    {
        $code = $this->service->generate(null, null);

        $this->assertMatchesRegularExpression('/^PKG-[A-Z0-9]{8}$/', $code);
    }

    public function test_generate_fallback_code_for_unknown_city(): void
    {
        $code = $this->service->generate('UnknownPlace', null);

        $this->assertMatchesRegularExpression('/^PKG-[A-Z0-9]{8}$/', $code);
    }

    public function test_generate_with_trip_suffix(): void
    {
        $user = User::factory()->create();
        $dateStr = now()->format('md');

        $trip1 = Trip::create([
            'transporter_id' => $user->id,
            'origin_city' => 'Madrid',
            'origin_country' => 'ES',
            'destination_city' => 'Valencia',
            'destination_country' => 'ES',
            'departure_date' => now(),
            'status' => 'planned',
        ]);

        $code1 = $this->service->generate('Valencia', $trip1->id);
        $this->createPackageWithCode($code1, $trip1->id);

        $this->assertEquals("VLC-{$dateStr}-01", $code1);

        $trip2 = Trip::create([
            'transporter_id' => $user->id,
            'origin_city' => 'Madrid',
            'origin_country' => 'ES',
            'destination_city' => 'Valencia',
            'destination_country' => 'ES',
            'departure_date' => now(),
            'status' => 'planned',
        ]);

        $code2 = $this->service->generate('Valencia', $trip2->id);
        $this->createPackageWithCode($code2, $trip2->id);

        $this->assertEquals("VLC2-{$dateStr}-01", $code2);
    }

    public function test_trip_reuses_existing_suffix(): void
    {
        $user = User::factory()->create();
        $dateStr = now()->format('md');

        $trip1 = Trip::create([
            'transporter_id' => $user->id,
            'origin_city' => 'Madrid',
            'origin_country' => 'ES',
            'destination_city' => 'Valencia',
            'destination_country' => 'ES',
            'departure_date' => now(),
            'status' => 'planned',
        ]);

        $code1 = $this->service->generate('Valencia', $trip1->id);
        $this->createPackageWithCode($code1, $trip1->id);

        $code2 = $this->service->generate('Valencia', $trip1->id);
        $this->createPackageWithCode($code2, $trip1->id);

        $this->assertEquals("VLC-{$dateStr}-01", $code1);
        $this->assertEquals("VLC-{$dateStr}-02", $code2);
    }

    public function test_different_cities_independent_sequences(): void
    {
        $dateStr = now()->format('md');

        $code1 = $this->service->generate('Valencia', null);
        $this->createPackageWithCode($code1);

        $code2 = $this->service->generate('Madrid', null);
        $this->createPackageWithCode($code2);

        $this->assertEquals("VLC-{$dateStr}-01", $code1);
        $this->assertEquals("MAD-{$dateStr}-01", $code2);
    }

    public function test_generate_public_id_format(): void
    {
        $publicId = $this->service->generatePublicId();

        $this->assertMatchesRegularExpression('/^PKG-[A-Z0-9]{8}$/', $publicId);
    }

    public function test_generate_unique_public_ids(): void
    {
        $ids = [];
        for ($i = 0; $i < 50; $i++) {
            $id = $this->service->generatePublicId();
            $this->assertNotContains($id, $ids, 'Duplicate public_id generated');
            $ids[] = $id;
        }
    }

    public function test_package_model_auto_generates_codes(): void
    {
        $user = User::factory()->create();

        $package = Package::create([
            'transporter_id' => $user->id,
            'sender_name' => 'Test Sender',
            'receiver_name' => 'Test Receiver',
            'receiver_city' => 'Valencia',
            'status' => 'pending',
        ]);

        $dateStr = now()->format('md');
        $this->assertEquals("VLC-{$dateStr}-01", $package->tracking_code);
        $this->assertNotNull($package->public_id);
        $this->assertMatchesRegularExpression('/^PKG-[A-Z0-9]{8}$/', $package->public_id);
    }

    public function test_package_search_by_public_id(): void
    {
        $user = User::factory()->create();

        $package = Package::create([
            'transporter_id' => $user->id,
            'sender_name' => 'Test Sender',
            'receiver_name' => 'Test Receiver',
            'receiver_city' => 'Valencia',
            'status' => 'pending',
        ]);

        $result = Package::search($package->public_id)->first();
        $this->assertNotNull($result);
        $this->assertEquals($package->id, $result->id);
    }

    public function test_uses_trip_departure_date_instead_of_today(): void
    {
        $user = User::factory()->create();

        $trip = Trip::create([
            'transporter_id' => $user->id,
            'origin_city' => 'Madrid',
            'origin_country' => 'ES',
            'destination_city' => 'Valencia',
            'destination_country' => 'ES',
            'departure_date' => '2026-03-15',
            'status' => 'planned',
        ]);

        $code = $this->service->generate('Valencia', $trip->id);

        $this->assertStringContainsString('-0315-', $code);
    }

    private function createPackageWithCode(string $trackingCode, ?string $tripId = null): Package
    {
        $user = User::factory()->create();

        return Package::create([
            'tracking_code' => $trackingCode,
            'transporter_id' => $user->id,
            'sender_name' => 'Test',
            'receiver_name' => 'Test',
            'receiver_city' => 'Valencia',
            'status' => 'pending',
            'trip_id' => $tripId,
        ]);
    }
}
