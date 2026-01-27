<?php

namespace App\Modules\Trips\Models;

use App\Models\User;
use App\Modules\Packages\Models\Package;
use App\Modules\Routes\Models\Route;
use App\Shared\Enums\TripStatus;
use App\Shared\Traits\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Trip extends Model
{
    use HasFactory, HasUuid, SoftDeletes;

    protected $fillable = [
        'route_id',
        'transporter_id',
        'origin_city',
        'origin_country',
        'destination_city',
        'destination_country',
        'departure_date',
        'departure_time',
        'estimated_arrival_date',
        'actual_arrival_date',
        'status',
        'vehicle_info',
        'notes',
        'price_per_kg',
        'minimum_price',
        'price_multiplier',
        'currency',
    ];

    protected $casts = [
        'departure_date' => 'date',
        'departure_time' => 'datetime:H:i',
        'estimated_arrival_date' => 'date',
        'actual_arrival_date' => 'date',
        'status' => TripStatus::class,
        'vehicle_info' => 'array',
        'price_per_kg' => 'decimal:2',
        'minimum_price' => 'decimal:2',
        'price_multiplier' => 'decimal:2',
    ];

    public function route(): BelongsTo
    {
        return $this->belongsTo(Route::class);
    }

    public function transporter(): BelongsTo
    {
        return $this->belongsTo(User::class, 'transporter_id');
    }

    public function stops(): HasMany
    {
        return $this->hasMany(TripStop::class)->orderBy('order');
    }

    public function packages(): HasMany
    {
        return $this->hasMany(Package::class);
    }

    public function getPackagesCountAttribute(): int
    {
        return $this->packages()->count();
    }

    public function getNameAttribute(): string
    {
        return "{$this->origin_city} - {$this->destination_city}";
    }

    public function scopeForTransporter($query, string $transporterId)
    {
        return $query->where('transporter_id', $transporterId);
    }

    public function scopeUpcoming($query)
    {
        return $query->where('departure_date', '>=', now()->toDateString())
            ->where('status', TripStatus::PLANNED);
    }

    public function scopeActive($query)
    {
        return $query->where('status', TripStatus::IN_PROGRESS);
    }

    public function scopePlanned($query)
    {
        return $query->where('status', TripStatus::PLANNED);
    }

    public function scopeByStatus($query, TripStatus|string $status)
    {
        $statusValue = $status instanceof TripStatus ? $status->value : $status;

        return $query->where('status', $statusValue);
    }

    public function scopeByDateRange($query, ?string $from, ?string $to)
    {
        if ($from) {
            $query->where('departure_date', '>=', $from);
        }
        if ($to) {
            $query->where('departure_date', '<=', $to);
        }

        return $query;
    }
}
