<?php

namespace App\Modules\Trips\Models;

use App\Shared\Enums\TripStopStatus;
use App\Shared\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TripStop extends Model
{
    use HasUuid;

    protected $fillable = [
        'trip_id',
        'city',
        'country',
        'order',
        'status',
        'arrived_at',
        'departed_at',
    ];

    protected $casts = [
        'order' => 'integer',
        'status' => TripStopStatus::class,
        'arrived_at' => 'datetime',
        'departed_at' => 'datetime',
    ];

    public function trip(): BelongsTo
    {
        return $this->belongsTo(Trip::class);
    }
}
