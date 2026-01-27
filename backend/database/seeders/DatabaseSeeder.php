<?php

namespace Database\Seeders;

use App\Models\User;
use App\Shared\Enums\DriverStatus;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        // Primero crear roles
        $this->call(RoleSeeder::class);

        // Super Admin
        $admin = User::factory()->create([
            'name' => 'Admin',
            'email' => 'admin@vezuway.com',
        ]);
        $admin->assignRole('super_admin');

        // Driver aprobado
        $driver = User::factory()->create([
            'name' => 'Driver Aprobado',
            'email' => 'driver@vezuway.com',
            'driver_status' => DriverStatus::APPROVED,
        ]);
        $driver->assignRole('driver');

        // Driver pendiente
        $pending = User::factory()->create([
            'name' => 'Driver Pendiente',
            'email' => 'pending@vezuway.com',
            'driver_status' => DriverStatus::PENDING,
        ]);
        $pending->assignRole('driver');

        // Cliente
        $client = User::factory()->create([
            'name' => 'Cliente Test',
            'email' => 'client@vezuway.com',
        ]);
        $client->assignRole('client');

        // Usuario legacy para testing
        User::factory()->create([
            'name' => 'Test User',
            'email' => 'test@example.com',
        ]);

        $this->call([
            PackageSeeder::class,
        ]);
    }
}
