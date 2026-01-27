<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('routes', function (Blueprint $table) {
            // Add new template-specific fields
            $table->string('name', 200)->nullable()->after('transporter_id');
            $table->text('description')->nullable()->after('name');
            $table->boolean('is_active')->default(true)->after('description');
            $table->integer('estimated_duration_hours')->nullable()->after('is_active');

            // Drop instance-specific columns
            $table->dropColumn([
                'departure_date',
                'estimated_arrival_date',
                'actual_arrival_date',
                'status',
            ]);
        });

        // Add index for active templates
        Schema::table('routes', function (Blueprint $table) {
            $table->index(['transporter_id', 'is_active']);
        });
    }

    public function down(): void
    {
        Schema::table('routes', function (Blueprint $table) {
            // Restore instance-specific columns
            $table->date('departure_date')->nullable()->after('destination_longitude');
            $table->date('estimated_arrival_date')->nullable()->after('departure_date');
            $table->date('actual_arrival_date')->nullable()->after('estimated_arrival_date');
            $table->string('status', 50)->default('planned')->after('actual_arrival_date');

            // Drop template-specific fields
            $table->dropColumn([
                'name',
                'description',
                'is_active',
                'estimated_duration_hours',
            ]);

            // Drop indexes
            $table->dropIndex(['transporter_id', 'is_active']);
        });
    }
};
