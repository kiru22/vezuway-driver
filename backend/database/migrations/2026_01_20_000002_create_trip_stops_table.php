<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('trip_stops', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('trip_id')->constrained('trips')->onDelete('cascade');

            $table->string('city', 100);
            $table->string('country', 2);
            $table->smallInteger('order')->default(0);
            $table->string('status', 50)->default('pending');
            $table->timestamp('arrived_at')->nullable();
            $table->timestamp('departed_at')->nullable();

            $table->timestamps();

            $table->unique(['trip_id', 'order']);
            $table->index('status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('trip_stops');
    }
};
