<?php

namespace App\Modules\Auth\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $avatarUrl = $this->getFirstMediaUrl('avatar', 'thumb') ?: $this->avatar_url;

        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'phone' => $this->phone,
            'locale' => $this->locale,
            'theme_preference' => $this->theme_preference ?? 'dark',
            'avatar_url' => $avatarUrl,
            'google_id' => $this->google_id,
            'email_verified_at' => $this->email_verified_at,
            'role' => $this->roles->first()?->name,
            'driver_status' => $this->driver_status?->value,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
