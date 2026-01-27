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
        Schema::table('packages', function (Blueprint $table) {
            $table->foreignUuid('sender_contact_id')
                ->nullable()
                ->after('trip_id')
                ->constrained('contacts')
                ->onDelete('set null');

            $table->foreignUuid('receiver_contact_id')
                ->nullable()
                ->after('sender_contact_id')
                ->constrained('contacts')
                ->onDelete('set null');

            $table->index('sender_contact_id');
            $table->index('receiver_contact_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('packages', function (Blueprint $table) {
            $table->dropForeign(['sender_contact_id']);
            $table->dropForeign(['receiver_contact_id']);
            $table->dropColumn(['sender_contact_id', 'receiver_contact_id']);
        });
    }
};
