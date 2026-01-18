<?php

namespace App\Modules\Routes\Models;

use App\Shared\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class RouteStop extends Model
{
    use HasUuid, SoftDeletes;

    protected $fillable = [
        'route_id',
        'city',
        'country',
        'order',
    ];

    protected $casts = [
        'order' => 'integer',
    ];

    public function route(): BelongsTo
    {
        return $this->belongsTo(Route::class);
    }
}
