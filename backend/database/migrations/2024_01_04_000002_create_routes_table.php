<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('routes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('transporter_id')->constrained('users')->onDelete('cascade');

            $table->string('origin_city', 100);
            $table->string('origin_country', 2);
            $table->decimal('origin_latitude', 10, 8)->nullable();
            $table->decimal('origin_longitude', 11, 8)->nullable();

            $table->string('destination_city', 100);
            $table->string('destination_country', 2);
            $table->decimal('destination_latitude', 10, 8)->nullable();
            $table->decimal('destination_longitude', 11, 8)->nullable();

            $table->date('departure_date');
            $table->date('estimated_arrival_date')->nullable();
            $table->date('actual_arrival_date')->nullable();

            $table->string('status', 50)->default('planned');
            $table->json('vehicle_info')->nullable();
            $table->text('notes')->nullable();

            $table->timestamps();
            $table->softDeletes();

            $table->index('transporter_id');
            $table->index('status');
            $table->index(['departure_date', 'estimated_arrival_date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('routes');
    }
};
