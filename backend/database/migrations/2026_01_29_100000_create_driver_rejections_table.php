<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('driver_rejections', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->constrained()->cascadeOnDelete();
            $table->text('rejection_reason')->nullable();
            $table->text('appeal_text')->nullable();
            $table->timestamp('rejected_at');
            $table->timestamp('appealed_at')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'rejected_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('driver_rejections');
    }
};
