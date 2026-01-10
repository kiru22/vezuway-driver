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
        DB::statement('ALTER TABLE packages ALTER COLUMN sender_name DROP NOT NULL');
        DB::statement('ALTER TABLE packages ALTER COLUMN sender_address DROP NOT NULL');
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        DB::statement('ALTER TABLE packages ALTER COLUMN sender_name SET NOT NULL');
        DB::statement('ALTER TABLE packages ALTER COLUMN sender_address SET NOT NULL');
    }
};
