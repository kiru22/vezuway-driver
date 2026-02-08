<?php

namespace App\Modules\Packages\Models;

use App\Models\User;
use App\Modules\Contacts\Models\Contact;
use App\Modules\Packages\Services\TrackingCodeService;
use App\Modules\Routes\Models\Route;
use App\Modules\Trips\Models\Trip;
use App\Shared\Enums\PackageStatus;
use App\Shared\Enums\TripStatus;
use App\Shared\Traits\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;
use Spatie\MediaLibrary\HasMedia;
use Spatie\MediaLibrary\InteractsWithMedia;
use Spatie\MediaLibrary\MediaCollections\Models\Media;

class Package extends Model implements HasMedia
{
    use HasFactory, HasUuid, InteractsWithMedia, SoftDeletes;

    protected $fillable = [
        'tracking_code',
        'public_id',
        'transporter_id',
        'route_id',
        'trip_id',
        'sender_contact_id',
        'receiver_contact_id',
        'sender_name',
        'sender_phone',
        'sender_address',
        'sender_city',
        'sender_country',
        'sender_latitude',
        'sender_longitude',
        'receiver_name',
        'receiver_phone',
        'receiver_address',
        'receiver_city',
        'receiver_country',
        'receiver_latitude',
        'receiver_longitude',
        'nova_post_number',
        'weight_kg',
        'length_cm',
        'width_cm',
        'height_cm',
        'quantity',
        'description',
        'declared_value',
        'status',
        'scanned_image_url',
        'ocr_confidence',
        'ocr_raw_data',
        'notes',
        'metadata',
    ];

    protected $casts = [
        'status' => PackageStatus::class,
        'weight_kg' => 'decimal:2',
        'declared_value' => 'decimal:2',
        'ocr_confidence' => 'decimal:2',
        'ocr_raw_data' => 'array',
        'metadata' => 'array',
        'sender_latitude' => 'decimal:8',
        'sender_longitude' => 'decimal:8',
        'receiver_latitude' => 'decimal:8',
        'receiver_longitude' => 'decimal:8',
    ];

    protected static function booted(): void
    {
        static::creating(function ($package) {
            $service = app(TrackingCodeService::class);

            if (empty($package->tracking_code)) {
                $package->tracking_code = $service->generate(
                    $package->receiver_city,
                    $package->trip_id,
                );
            }

            if (empty($package->public_id)) {
                $package->public_id = $service->generatePublicId();
            }
        });
    }

    public function transporter(): BelongsTo
    {
        return $this->belongsTo(User::class, 'transporter_id');
    }

    public function route(): BelongsTo
    {
        return $this->belongsTo(Route::class);
    }

    public function trip(): BelongsTo
    {
        return $this->belongsTo(Trip::class);
    }

    public function senderContact(): BelongsTo
    {
        return $this->belongsTo(Contact::class, 'sender_contact_id');
    }

    public function receiverContact(): BelongsTo
    {
        return $this->belongsTo(Contact::class, 'receiver_contact_id');
    }

    public function statusHistory(): HasMany
    {
        return $this->hasMany(PackageStatusHistory::class)->orderBy('created_at', 'desc');
    }

    public function recordStatusChange(
        PackageStatus $status,
        ?string $userId = null,
        ?string $notes = null,
        ?float $latitude = null,
        ?float $longitude = null
    ): void {
        $this->statusHistory()->create([
            'status' => $status->value,
            'notes' => $notes,
            'created_by' => $userId,
            'latitude' => $latitude,
            'longitude' => $longitude,
        ]);

        $this->update(['status' => $status]);

        if ($status === PackageStatus::DELIVERED) {
            $this->autoCompleteTripIfAllDelivered();
        }
    }

    /**
     * Auto-complete the trip when all its packages are delivered.
     */
    private function autoCompleteTripIfAllDelivered(): void
    {
        if (! $this->trip_id) {
            return;
        }

        $trip = $this->trip;
        if ($trip === null || $trip->status === TripStatus::COMPLETED) {
            return;
        }

        $hasPendingPackages = $trip->packages()
            ->where('id', '!=', $this->id)
            ->where('status', '!=', PackageStatus::DELIVERED->value)
            ->exists();

        if (! $hasPendingPackages) {
            $trip->update([
                'status' => TripStatus::COMPLETED->value,
                'actual_arrival_date' => now(),
            ]);
        }
    }

    public function scopeForTransporter($query, string $transporterId)
    {
        return $query->where('transporter_id', $transporterId);
    }

    public function scopeByStatus($query, PackageStatus $status)
    {
        return $query->where('status', $status);
    }

    public function scopeSearch($query, string $term)
    {
        $escaped = str_replace(['%', '_'], ['\\%', '\\_'], $term);

        return $query->where(function ($q) use ($escaped) {
            $q->where('tracking_code', 'like', "%{$escaped}%")
                ->orWhere('public_id', 'like', "%{$escaped}%")
                ->orWhere('sender_name', 'like', "%{$escaped}%")
                ->orWhere('receiver_name', 'like', "%{$escaped}%")
                ->orWhere('sender_city', 'like', "%{$escaped}%")
                ->orWhere('receiver_city', 'like', "%{$escaped}%");
        });
    }

    public function scopeForContact($query, string $contactId)
    {
        return $query->where(function ($q) use ($contactId) {
            $q->where('sender_contact_id', $contactId)
                ->orWhere('receiver_contact_id', $contactId);
        });
    }

    public function registerMediaCollections(): void
    {
        $this->addMediaCollection('images')
            ->useDisk('public');
    }

    public function registerMediaConversions(?Media $media = null): void
    {
        $this->addMediaConversion('thumb')
            ->width(300)
            ->height(300)
            ->sharpen(10)
            ->nonQueued();
    }
}
