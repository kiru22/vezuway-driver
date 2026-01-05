<?php

namespace App\Modules\Routes\Models;

use App\Models\User;
use App\Modules\Packages\Models\Package;
use App\Shared\Enums\RouteStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Route extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'transporter_id',
        'origin_city',
        'origin_country',
        'origin_latitude',
        'origin_longitude',
        'destination_city',
        'destination_country',
        'destination_latitude',
        'destination_longitude',
        'departure_date',
        'estimated_arrival_date',
        'actual_arrival_date',
        'status',
        'vehicle_info',
        'notes',
    ];

    protected $casts = [
        'departure_date' => 'date',
        'estimated_arrival_date' => 'date',
        'actual_arrival_date' => 'date',
        'status' => RouteStatus::class,
        'vehicle_info' => 'array',
        'origin_latitude' => 'decimal:8',
        'origin_longitude' => 'decimal:8',
        'destination_latitude' => 'decimal:8',
        'destination_longitude' => 'decimal:8',
    ];

    public function transporter(): BelongsTo
    {
        return $this->belongsTo(User::class, 'transporter_id');
    }

    public function packages(): HasMany
    {
        return $this->hasMany(Package::class);
    }

    public function schedules(): HasMany
    {
        return $this->hasMany(RouteSchedule::class)->orderBy('departure_date');
    }

    public function getPackagesCountAttribute(): int
    {
        return $this->packages()->count();
    }

    public function scopeForTransporter($query, int $transporterId)
    {
        return $query->where('transporter_id', $transporterId);
    }

    public function scopeUpcoming($query)
    {
        return $query->where('departure_date', '>=', now()->toDateString())
            ->where('status', RouteStatus::PLANNED);
    }

    public function scopeActive($query)
    {
        return $query->where('status', RouteStatus::IN_PROGRESS);
    }
}
