<?php

namespace App\Modules\Routes\Models;

use App\Models\User;
use App\Modules\Trips\Models\Trip;
use App\Shared\Traits\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Route extends Model
{
    use HasFactory, HasUuid, SoftDeletes;

    protected $fillable = [
        'transporter_id',
        'name',
        'description',
        'is_active',
        'estimated_duration_hours',
        'origin_city',
        'origin_country',
        'origin_latitude',
        'origin_longitude',
        'destination_city',
        'destination_country',
        'destination_latitude',
        'destination_longitude',
        'vehicle_info',
        'notes',
        'price_per_kg',
        'minimum_price',
        'price_multiplier',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'estimated_duration_hours' => 'integer',
        'vehicle_info' => 'array',
        'origin_latitude' => 'decimal:8',
        'origin_longitude' => 'decimal:8',
        'destination_latitude' => 'decimal:8',
        'destination_longitude' => 'decimal:8',
        'price_per_kg' => 'decimal:2',
        'minimum_price' => 'decimal:2',
        'price_multiplier' => 'decimal:2',
    ];

    public function transporter(): BelongsTo
    {
        return $this->belongsTo(User::class, 'transporter_id');
    }

    public function stops(): HasMany
    {
        return $this->hasMany(RouteStop::class)->orderBy('order');
    }

    public function trips(): HasMany
    {
        return $this->hasMany(Trip::class);
    }

    public function getDisplayNameAttribute(): string
    {
        return $this->name ?? "{$this->origin_city} - {$this->destination_city}";
    }

    public function scopeForTransporter($query, string $transporterId)
    {
        return $query->where('transporter_id', $transporterId);
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }
}
