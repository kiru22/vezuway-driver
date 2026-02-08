<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        DB::statement('CREATE EXTENSION IF NOT EXISTS pg_trgm');

        Schema::create('cities', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->integer('geoname_id')->unique();
            $table->string('name', 200);
            $table->string('name_local', 200);
            $table->string('name_es', 200)->nullable();
            $table->string('name_uk', 200)->nullable();
            $table->char('country_code', 2);
            $table->string('admin1_name', 200)->nullable();
            $table->decimal('latitude', 10, 8)->nullable();
            $table->decimal('longitude', 11, 8)->nullable();
            $table->integer('population')->default(0);
            $table->string('feature_code', 10)->nullable();
            $table->text('search_text');
            $table->string('tracking_code', 3)->nullable()->index();
            $table->timestamps();

            $table->index('country_code');
            $table->index(['country_code', 'population']);
        });

        DB::statement('CREATE INDEX cities_search_text_trgm ON cities USING GIN (search_text gin_trgm_ops)');
    }

    public function down(): void
    {
        Schema::dropIfExists('cities');
    }
};
