<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('excel_imports', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('transporter_id')->constrained('users')->onDelete('cascade');
            $table->string('file_name');
            $table->text('file_url');
            $table->string('status', 50)->default('pending');
            $table->integer('total_rows')->default(0);
            $table->integer('processed_rows')->default(0);
            $table->integer('failed_rows')->default(0);
            $table->json('error_log')->nullable();
            $table->timestamp('started_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();

            $table->index('transporter_id');
            $table->index('status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('excel_imports');
    }
};
