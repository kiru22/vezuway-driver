<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;

class RoleSeeder extends Seeder
{
    public function run(): void
    {
        // Limpiar cache de roles
        app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();

        // Crear roles
        Role::firstOrCreate(['name' => 'client']);
        Role::firstOrCreate(['name' => 'driver']);
        Role::firstOrCreate(['name' => 'super_admin']);
    }
}
