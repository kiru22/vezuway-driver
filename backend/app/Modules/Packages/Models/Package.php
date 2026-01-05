<?php

namespace App\Modules\Packages\Models;

use App\Models\User;
use App\Modules\Routes\Models\Route;
use App\Shared\Enums\PackageStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class Package extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'tracking_code',
        'transporter_id',
        'route_id',
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
        'weight_kg',
        'length_cm',
        'width_cm',
        'height_cm',
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

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($package) {
            if (empty($package->tracking_code)) {
                $package->tracking_code = self::generateTrackingCode();
            }
        });
    }

    public static function generateTrackingCode(): string
    {
        do {
            $code = 'PKG-'.strtoupper(Str::random(8));
        } while (self::where('tracking_code', $code)->exists());

        return $code;
    }

    public function transporter(): BelongsTo
    {
        return $this->belongsTo(User::class, 'transporter_id');
    }

    public function route(): BelongsTo
    {
        return $this->belongsTo(Route::class);
    }

    public function statusHistory(): HasMany
    {
        return $this->hasMany(PackageStatusHistory::class)->orderBy('created_at', 'desc');
    }

    public function recordStatusChange(PackageStatus $status, ?int $userId = null, ?string $notes = null): void
    {
        $this->statusHistory()->create([
            'status' => $status->value,
            'notes' => $notes,
            'created_by' => $userId,
        ]);

        $this->update(['status' => $status]);
    }

    public function scopeForTransporter($query, int $transporterId)
    {
        return $query->where('transporter_id', $transporterId);
    }

    public function scopeByStatus($query, PackageStatus $status)
    {
        return $query->where('status', $status);
    }

    public function scopeSearch($query, string $term)
    {
        return $query->where(function ($q) use ($term) {
            $q->where('tracking_code', 'like', "%{$term}%")
                ->orWhere('sender_name', 'like', "%{$term}%")
                ->orWhere('receiver_name', 'like', "%{$term}%")
                ->orWhere('sender_city', 'like', "%{$term}%")
                ->orWhere('receiver_city', 'like', "%{$term}%");
        });
    }
}
