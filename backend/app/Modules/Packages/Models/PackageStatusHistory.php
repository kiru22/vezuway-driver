<?php

namespace App\Modules\Packages\Models;

use App\Models\User;
use App\Shared\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PackageStatusHistory extends Model
{
    use HasUuid;

    public $timestamps = false;

    protected $table = 'package_status_history';

    protected $fillable = [
        'package_id',
        'status',
        'latitude',
        'longitude',
        'notes',
        'created_by',
        'created_at',
    ];

    protected $casts = [
        'created_at' => 'datetime',
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
    ];

    public function package(): BelongsTo
    {
        return $this->belongsTo(Package::class);
    }

    public function createdBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}
