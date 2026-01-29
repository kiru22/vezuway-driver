<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        DB::statement('ALTER TABLE packages ALTER COLUMN receiver_address DROP NOT NULL');
        DB::statement('ALTER TABLE packages ALTER COLUMN receiver_name DROP NOT NULL');
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Update existing NULL values before adding constraint
        DB::statement("UPDATE packages SET receiver_address = '' WHERE receiver_address IS NULL");
        DB::statement("UPDATE packages SET receiver_name = '' WHERE receiver_name IS NULL");

        DB::statement('ALTER TABLE packages ALTER COLUMN receiver_address SET NOT NULL');
        DB::statement('ALTER TABLE packages ALTER COLUMN receiver_name SET NOT NULL');
    }
};
