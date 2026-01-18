<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('route_schedules', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('route_id')->constrained()->onDelete('cascade');
            $table->date('departure_date');
            $table->date('estimated_arrival_date')->nullable();
            $table->string('status', 50)->default('planned');
            $table->timestamps();

            // Prevent duplicate dates for the same route
            $table->unique(['route_id', 'departure_date']);

            // Index for date-based queries
            $table->index('departure_date');
            $table->index(['route_id', 'status']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('route_schedules');
    }
};
