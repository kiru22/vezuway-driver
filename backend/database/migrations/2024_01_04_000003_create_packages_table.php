<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('packages', function (Blueprint $table) {
            $table->id();
            $table->string('tracking_code', 50)->unique();
            $table->foreignId('transporter_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('route_id')->nullable()->constrained('routes')->onDelete('set null');

            // Sender
            $table->string('sender_name');
            $table->string('sender_phone', 50)->nullable();
            $table->text('sender_address');
            $table->string('sender_city', 100)->nullable();
            $table->string('sender_country', 2)->default('UA');
            $table->decimal('sender_latitude', 10, 8)->nullable();
            $table->decimal('sender_longitude', 11, 8)->nullable();

            // Receiver
            $table->string('receiver_name');
            $table->string('receiver_phone', 50)->nullable();
            $table->text('receiver_address');
            $table->string('receiver_city', 100)->nullable();
            $table->string('receiver_country', 2)->default('ES');
            $table->decimal('receiver_latitude', 10, 8)->nullable();
            $table->decimal('receiver_longitude', 11, 8)->nullable();

            // Package details
            $table->decimal('weight_kg', 10, 2)->nullable();
            $table->integer('length_cm')->nullable();
            $table->integer('width_cm')->nullable();
            $table->integer('height_cm')->nullable();
            $table->text('description')->nullable();
            $table->decimal('declared_value', 10, 2)->nullable();

            // Status
            $table->string('status', 50)->default('pending');

            // OCR
            $table->text('scanned_image_url')->nullable();
            $table->decimal('ocr_confidence', 5, 2)->nullable();
            $table->json('ocr_raw_data')->nullable();

            // Metadata
            $table->text('notes')->nullable();
            $table->json('metadata')->nullable();

            $table->timestamps();
            $table->softDeletes();

            $table->index('transporter_id');
            $table->index('route_id');
            $table->index('status');
            $table->index('tracking_code');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('packages');
    }
};
