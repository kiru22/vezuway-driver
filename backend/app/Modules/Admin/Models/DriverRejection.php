<?php

namespace App\Modules\Admin\Models;

use App\Models\User;
use App\Shared\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DriverRejection extends Model
{
    use HasUuid;

    protected $fillable = [
        'user_id',
        'rejection_reason',
        'appeal_text',
        'rejected_at',
        'appealed_at',
    ];

    protected function casts(): array
    {
        return [
            'rejected_at' => 'datetime',
            'appealed_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function hasAppealed(): bool
    {
        return $this->appealed_at !== null;
    }
}
