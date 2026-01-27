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
        Schema::create('contacts', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->nullable()->constrained('users')->onDelete('set null');
            $table->foreignUuid('created_by_user_id')->nullable()->constrained('users')->onDelete('set null');

            $table->string('name');
            $table->string('email')->nullable();
            $table->string('phone', 50)->nullable();
            $table->text('address')->nullable();
            $table->string('city', 100)->nullable();
            $table->string('country', 2)->nullable();
            $table->decimal('latitude', 10, 8)->nullable();
            $table->decimal('longitude', 11, 8)->nullable();

            $table->text('notes')->nullable();
            $table->json('metadata')->nullable();
            $table->boolean('is_verified')->default(false);

            $table->timestamp('last_package_at')->nullable();
            $table->unsignedInteger('total_packages_sent')->default(0);
            $table->unsignedInteger('total_packages_received')->default(0);

            $table->timestamps();
            $table->softDeletes();

            // Índices para búsqueda y ownership
            $table->index('created_by_user_id');
            $table->index('user_id');
            $table->index('email');
            $table->index('phone');
            $table->index(['name', 'email', 'phone']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('contacts');
    }
};
