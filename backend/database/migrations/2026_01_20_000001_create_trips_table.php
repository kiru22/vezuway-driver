<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('trips', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('route_id')->nullable()->constrained('routes')->onDelete('set null');
            $table->foreignUuid('transporter_id')->constrained('users')->onDelete('cascade');

            $table->string('origin_city', 100);
            $table->string('origin_country', 2);
            $table->string('destination_city', 100);
            $table->string('destination_country', 2);

            $table->date('departure_date');
            $table->time('departure_time')->nullable();
            $table->date('estimated_arrival_date')->nullable();
            $table->date('actual_arrival_date')->nullable();

            $table->string('status', 50)->default('planned');
            $table->json('vehicle_info')->nullable();
            $table->text('notes')->nullable();

            $table->unsignedDecimal('price_per_kg', 10, 2)->nullable();
            $table->unsignedDecimal('minimum_price', 10, 2)->nullable();
            $table->unsignedDecimal('price_multiplier', 5, 2)->default(1.00);
            $table->string('currency', 3)->default('EUR');

            $table->timestamps();
            $table->softDeletes();

            $table->index('transporter_id');
            $table->index('route_id');
            $table->index('status');
            $table->index(['departure_date', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('trips');
    }
};
