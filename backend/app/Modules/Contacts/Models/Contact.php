<?php

namespace App\Modules\Contacts\Models;

use App\Models\User;
use App\Modules\Packages\Models\Package;
use App\Shared\Traits\HasUuid;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Contact extends Model
{
    use HasUuid;
    use SoftDeletes;

    protected $fillable = [
        'user_id',
        'created_by_user_id',
        'name',
        'email',
        'phone',
        'address',
        'city',
        'country',
        'latitude',
        'longitude',
        'notes',
        'metadata',
        'is_verified',
        'last_package_at',
        'total_packages_sent',
        'total_packages_received',
    ];

    protected $casts = [
        'metadata' => 'array',
        'is_verified' => 'boolean',
        'last_package_at' => 'datetime',
        'total_packages_sent' => 'integer',
        'total_packages_received' => 'integer',
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
    ];

    /**
     * Usuario vinculado (nullable - puede no tener cuenta)
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    /**
     * Transportista que creó el contacto
     */
    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by_user_id');
    }

    /**
     * Paquetes donde este contacto es remitente
     */
    public function packagesAsSender(): HasMany
    {
        return $this->hasMany(Package::class, 'sender_contact_id');
    }

    /**
     * Paquetes donde este contacto es destinatario
     */
    public function packagesAsReceiver(): HasMany
    {
        return $this->hasMany(Package::class, 'receiver_contact_id');
    }

    /**
     * Scope: Filtrar contactos de un transportista específico
     */
    public function scopeForTransporter(Builder $query, string $userId): Builder
    {
        return $query->where('created_by_user_id', $userId);
    }

    /**
     * Scope: Buscar por nombre, email o teléfono
     */
    public function scopeSearch(Builder $query, string $term): Builder
    {
        return $query->where(function ($q) use ($term) {
            $q->where('name', 'ILIKE', "%{$term}%")
                ->orWhere('email', 'ILIKE', "%{$term}%")
                ->orWhere('phone', 'ILIKE', "%{$term}%");
        });
    }

    /**
     * Scope: Solo contactos verificados
     */
    public function scopeVerified(Builder $query): Builder
    {
        return $query->where('is_verified', true);
    }

    /**
     * Accessor: Dirección completa formateada
     */
    public function getFullAddressAttribute(): string
    {
        $parts = array_filter([
            $this->address,
            $this->city,
            $this->country,
        ]);

        return implode(', ', $parts);
    }

    /**
     * Accessor: Total de paquetes (enviados + recibidos)
     */
    public function getTotalPackagesAttribute(): int
    {
        return $this->total_packages_sent + $this->total_packages_received;
    }

    /**
     * Recalcular contadores desde la base de datos
     */
    public function updatePackageCounters(): void
    {
        $sent = $this->packagesAsSender()->count();
        $received = $this->packagesAsReceiver()->count();

        $lastPackage = Package::where('sender_contact_id', $this->id)
            ->orWhere('receiver_contact_id', $this->id)
            ->latest('created_at')
            ->first();

        $this->update([
            'total_packages_sent' => $sent,
            'total_packages_received' => $received,
            'last_package_at' => $lastPackage?->created_at,
        ]);
    }

    /**
     * Marcar contacto como verificado
     */
    public function markAsVerified(): void
    {
        $this->update(['is_verified' => true]);
    }

    /**
     * Vincular contacto a un usuario
     */
    public function linkToUser(string $userId): void
    {
        $this->update([
            'user_id' => $userId,
            'is_verified' => true,
        ]);
    }
}
