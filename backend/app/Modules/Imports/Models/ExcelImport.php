<?php

namespace App\Modules\Imports\Models;

use App\Models\User;
use App\Shared\Enums\ImportStatus;
use App\Shared\Traits\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ExcelImport extends Model
{
    use HasFactory, HasUuid;

    protected $fillable = [
        'transporter_id',
        'file_name',
        'file_url',
        'status',
        'total_rows',
        'processed_rows',
        'failed_rows',
        'error_log',
        'started_at',
        'completed_at',
    ];

    protected $casts = [
        'status' => ImportStatus::class,
        'error_log' => 'array',
        'started_at' => 'datetime',
        'completed_at' => 'datetime',
    ];

    public function transporter(): BelongsTo
    {
        return $this->belongsTo(User::class, 'transporter_id');
    }

    public function getProgressPercentageAttribute(): float
    {
        if ($this->total_rows === 0) {
            return 0;
        }

        return round(($this->processed_rows / $this->total_rows) * 100, 2);
    }

    public function markAsProcessing(): void
    {
        $this->update([
            'status' => ImportStatus::PROCESSING,
            'started_at' => now(),
        ]);
    }

    public function markAsCompleted(): void
    {
        $this->update([
            'status' => ImportStatus::COMPLETED,
            'completed_at' => now(),
        ]);
    }

    public function markAsFailed(array $errors = []): void
    {
        $this->update([
            'status' => ImportStatus::FAILED,
            'error_log' => $errors,
            'completed_at' => now(),
        ]);
    }

    public function incrementProcessed(): void
    {
        $this->increment('processed_rows');
    }

    public function incrementFailed(): void
    {
        $this->increment('failed_rows');
    }

    public function scopeForTransporter($query, string $transporterId)
    {
        return $query->where('transporter_id', $transporterId);
    }
}
