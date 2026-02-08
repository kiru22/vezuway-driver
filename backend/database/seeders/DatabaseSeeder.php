<?php

namespace Database\Seeders;

use App\Models\User;
use App\Shared\Enums\DriverStatus;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        // Primero crear roles
        $this->call(RoleSeeder::class);

        // Super Admin
        $admin = User::firstOrCreate(
            ['email' => 'admin@vezuway.com'],
            ['name' => 'Admin', 'password' => Hash::make('password')]
        );
        if (! $admin->hasRole('super_admin')) {
            $admin->assignRole('super_admin');
        }

        // Driver aprobado
        $driver = User::firstOrCreate(
            ['email' => 'driver@vezuway.com'],
            ['name' => 'Driver Aprobado', 'password' => Hash::make('password'), 'driver_status' => DriverStatus::APPROVED]
        );
        if (! $driver->hasRole('driver')) {
            $driver->assignRole('driver');
        }

        // Driver pendiente
        $pending = User::firstOrCreate(
            ['email' => 'pending@vezuway.com'],
            ['name' => 'Driver Pendiente', 'password' => Hash::make('password'), 'driver_status' => DriverStatus::PENDING]
        );
        if (! $pending->hasRole('driver')) {
            $pending->assignRole('driver');
        }

        // Cliente
        $client = User::firstOrCreate(
            ['email' => 'client@vezuway.com'],
            ['name' => 'Cliente Test', 'password' => Hash::make('password')]
        );
        if (! $client->hasRole('client')) {
            $client->assignRole('client');
        }

        // Usuario legacy para testing
        User::firstOrCreate(
            ['email' => 'test@example.com'],
            ['name' => 'Test User', 'password' => Hash::make('password')]
        );

        $this->call([
            PackageSeeder::class,
        ]);
    }
}
