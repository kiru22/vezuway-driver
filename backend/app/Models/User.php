<?php

namespace App\Models;

use App\Modules\Contacts\Models\Contact;
use App\Shared\Enums\DriverStatus;
use App\Shared\Traits\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Spatie\MediaLibrary\HasMedia;
use Spatie\MediaLibrary\InteractsWithMedia;
use Spatie\MediaLibrary\MediaCollections\Models\Media;
use Spatie\Permission\Traits\HasRoles;

class User extends Authenticatable implements HasMedia
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasApiTokens, HasFactory, HasRoles, HasUuid, InteractsWithMedia, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'phone',
        'locale',
        'theme_preference',
        'fcm_token',
        'google_id',
        'avatar_url',
        'driver_status',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
        'fcm_token',
        'google_id',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'driver_status' => DriverStatus::class,
        ];
    }

    /**
     * Contacto vinculado (si el usuario se registró desde un contacto existente)
     */
    public function contact(): HasOne
    {
        return $this->hasOne(Contact::class, 'user_id');
    }

    public function registerMediaCollections(): void
    {
        $this->addMediaCollection('avatar')
            ->singleFile()
            ->acceptsMimeTypes(['image/jpeg', 'image/png', 'image/webp']);
    }

    public function registerMediaConversions(?Media $media = null): void
    {
        $this->addMediaConversion('thumb')
            ->width(150)
            ->height(150)
            ->sharpen(10)
            ->performOnCollections('avatar');
    }

    // User Type Helper Methods
    public function isClient(): bool
    {
        return $this->hasRole('client');
    }

    public function isDriver(): bool
    {
        return $this->hasRole('driver');
    }

    public function isSuperAdmin(): bool
    {
        return $this->hasRole('super_admin');
    }

    public function isApprovedDriver(): bool
    {
        return $this->hasRole('driver') && $this->driver_status === DriverStatus::APPROVED;
    }

    public function isPendingDriver(): bool
    {
        return $this->hasRole('driver') && $this->driver_status === DriverStatus::PENDING;
    }

    public function needsRoleSelection(): bool
    {
        return $this->roles()->count() === 0;
    }
}
