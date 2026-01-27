<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * ⚠️ WARNING: This migration deletes ALL existing route data permanently.
     * This is necessary for the transition from instance-based routes to template-based routes.
     * Only run this if you understand the implications or on fresh databases.
     */
    public function up(): void
    {
        // Protect production environment from accidental data loss
        if (app()->environment('production')) {
            throw new \RuntimeException(
                'This migration cannot run in production. '.
                'If you need to run it, set ALLOW_DESTRUCTIVE_MIGRATIONS=true in your .env'
            );
        }

        // Allow override with explicit env variable
        if (! config('app.allow_destructive_migrations', false) && ! app()->environment('local', 'testing')) {
            throw new \RuntimeException(
                'This migration is destructive and requires explicit permission. '.
                'Set ALLOW_DESTRUCTIVE_MIGRATIONS=true in your .env to proceed.'
            );
        }

        // Clear route_id from packages (they will be assigned to trips)
        DB::table('packages')->update(['route_id' => null]);

        // Delete route schedules
        DB::table('route_schedules')->delete();

        // Delete route stops
        DB::table('route_stops')->delete();

        // Delete routes
        DB::table('routes')->delete();

        // Drop route_schedules table
        Schema::dropIfExists('route_schedules');
    }

    public function down(): void
    {
        // Recreate route_schedules table
        Schema::create('route_schedules', function ($table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('route_id')->constrained()->onDelete('cascade');
            $table->date('departure_date');
            $table->date('estimated_arrival_date')->nullable();
            $table->string('status', 50)->default('planned');
            $table->timestamps();

            $table->unique(['route_id', 'departure_date']);
            $table->index('departure_date');
            $table->index(['route_id', 'status']);
        });
    }
};
