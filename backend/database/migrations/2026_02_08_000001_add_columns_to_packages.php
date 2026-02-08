<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('packages', function (Blueprint $table) {
            $table->string('public_id', 20)->unique()->nullable()->after('tracking_code');
            $table->string('nova_post_number', 50)->nullable()->after('receiver_longitude');
        });
    }

    public function down(): void
    {
        Schema::table('packages', function (Blueprint $table) {
            $table->dropColumn(['public_id', 'nova_post_number']);
        });
    }
};
