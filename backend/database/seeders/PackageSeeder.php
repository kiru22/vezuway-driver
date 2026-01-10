<?php

namespace Database\Seeders;

use App\Modules\Packages\Models\Package;
use App\Modules\Routes\Models\Route;
use App\Shared\Enums\PackageStatus;
use Illuminate\Database\Seeder;

class PackageSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get first route or create one if none exists
        $route = Route::first();

        $packages = [
            [
                'sender_name' => 'Maria Garcia',
                'sender_phone' => '+34612345678',
                'sender_address' => 'Calle Mayor 15, Madrid',
                'sender_city' => 'Madrid',
                'sender_country' => 'ES',
                'receiver_name' => 'Olena Kovalenko',
                'receiver_phone' => '+380501234567',
                'receiver_address' => 'вул. Хрещатик 22, Київ',
                'receiver_city' => 'Київ',
                'receiver_country' => 'UA',
                'weight_kg' => 4.5,
                'quantity' => 2,
                'declared_value' => 150.00,
                'description' => 'Ropa y documentos',
                'status' => PackageStatus::IN_TRANSIT,
            ],
            [
                'sender_name' => 'Carlos Martinez',
                'sender_phone' => '+34698765432',
                'sender_address' => 'Av. Diagonal 450, Barcelona',
                'sender_city' => 'Barcelona',
                'sender_country' => 'ES',
                'receiver_name' => 'Andriy Shevchenko',
                'receiver_phone' => '+380671234567',
                'receiver_address' => 'пр. Свободи 28, Львів',
                'receiver_city' => 'Львів',
                'receiver_country' => 'UA',
                'weight_kg' => 8.0,
                'quantity' => 1,
                'declared_value' => 250.00,
                'description' => 'Electronica',
                'status' => PackageStatus::PENDING,
            ],
            [
                'sender_name' => 'Ana Lopez',
                'sender_phone' => '+34655443322',
                'sender_address' => 'Plaza Nueva 5, Sevilla',
                'sender_city' => 'Sevilla',
                'sender_country' => 'ES',
                'receiver_name' => 'Tetiana Bondar',
                'receiver_phone' => '+380931234567',
                'receiver_address' => 'вул. Дерибасівська 10, Одеса',
                'receiver_city' => 'Одеса',
                'receiver_country' => 'UA',
                'weight_kg' => 2.5,
                'quantity' => 3,
                'declared_value' => 80.00,
                'description' => 'Libros y juguetes',
                'status' => PackageStatus::PICKED_UP,
            ],
            [
                'sender_name' => 'Pablo Ruiz',
                'sender_phone' => '+34611223344',
                'sender_address' => 'Gran Via 100, Valencia',
                'sender_city' => 'Valencia',
                'sender_country' => 'ES',
                'receiver_name' => 'Mykola Petrov',
                'receiver_phone' => '+380441234567',
                'receiver_address' => 'вул. Сумська 45, Харків',
                'receiver_city' => 'Харків',
                'receiver_country' => 'UA',
                'weight_kg' => 12.0,
                'quantity' => 1,
                'declared_value' => 500.00,
                'description' => 'Herramientas',
                'status' => PackageStatus::CUSTOMS,
            ],
            [
                'sender_name' => 'Elena Fernandez',
                'sender_phone' => '+34699887766',
                'sender_address' => 'Calle Alcala 200, Madrid',
                'sender_city' => 'Madrid',
                'sender_country' => 'ES',
                'receiver_name' => 'Oksana Melnyk',
                'receiver_phone' => '+380961234567',
                'receiver_address' => 'вул. Соборна 15, Дніпро',
                'receiver_city' => 'Дніпро',
                'receiver_country' => 'UA',
                'weight_kg' => 3.0,
                'quantity' => 5,
                'declared_value' => 120.00,
                'description' => 'Cosmeticos y ropa',
                'status' => PackageStatus::DELIVERED,
            ],
            [
                'sender_name' => 'Javier Sanchez',
                'sender_phone' => '+34677889900',
                'sender_address' => 'Paseo de Gracia 50, Barcelona',
                'sender_city' => 'Barcelona',
                'sender_country' => 'ES',
                'receiver_name' => 'Vasyl Tkachenko',
                'receiver_phone' => '+380501112233',
                'receiver_address' => 'пр. Миру 30, Вінниця',
                'receiver_city' => 'Вінниця',
                'receiver_country' => 'UA',
                'weight_kg' => 6.5,
                'quantity' => 2,
                'declared_value' => 180.00,
                'description' => 'Medicamentos',
                'status' => PackageStatus::OUT_FOR_DELIVERY,
            ],
        ];

        foreach ($packages as $packageData) {
            if ($route) {
                $packageData['route_id'] = $route->id;
            }
            Package::create($packageData);
        }
    }
}
