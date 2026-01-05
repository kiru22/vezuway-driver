<?php

namespace App\Modules\Routes\Models;

use App\Shared\Enums\RouteStatus;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RouteSchedule extends Model
{
    protected $fillable = [
        'route_id',
        'departure_date',
        'estimated_arrival_date',
        'status',
    ];

    protected $casts = [
        'departure_date' => 'date',
        'estimated_arrival_date' => 'date',
        'status' => RouteStatus::class,
    ];

    public function route(): BelongsTo
    {
        return $this->belongsTo(Route::class);
    }

    public function scopeUpcoming($query)
    {
        return $query->where('departure_date', '>=', now()->toDateString())
            ->where('status', RouteStatus::PLANNED);
    }

    public function scopePlanned($query)
    {
        return $query->where('status', RouteStatus::PLANNED);
    }
}
