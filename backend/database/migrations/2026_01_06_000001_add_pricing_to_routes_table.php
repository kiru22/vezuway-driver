<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('routes', function (Blueprint $table) {
            $table->decimal('price_per_kg', 10, 2)->nullable()->after('notes');
            $table->decimal('minimum_price', 10, 2)->nullable()->after('price_per_kg');
            $table->decimal('price_multiplier', 5, 2)->nullable()->default(1.00)->after('minimum_price');
        });
    }

    public function down(): void
    {
        Schema::table('routes', function (Blueprint $table) {
            $table->dropColumn(['price_per_kg', 'minimum_price', 'price_multiplier']);
        });
    }
};
