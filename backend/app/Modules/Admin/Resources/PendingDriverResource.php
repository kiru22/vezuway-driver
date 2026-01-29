<?php

namespace App\Modules\Admin\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PendingDriverResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $avatarUrl = $this->getFirstMediaUrl('avatar', 'thumb') ?: $this->avatar_url;

        // Check if this is a reapplication (has previous rejections with appeal)
        $latestRejection = $this->latestRejection;
        $isReapplication = $latestRejection?->hasAppealed() ?? false;

        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'phone' => $this->phone,
            'locale' => $this->locale ?? 'es',
            'theme_preference' => $this->theme_preference ?? 'dark',
            'avatar_url' => $avatarUrl,
            'fcm_token' => $this->fcm_token,
            'google_id' => $this->google_id,
            'role' => $this->roles->first()?->name,
            'driver_status' => $this->driver_status?->value,
            'email_verified_at' => $this->email_verified_at,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'is_reapplication' => $isReapplication,
            'previous_rejection_reason' => $isReapplication ? $latestRejection->rejection_reason : null,
            'appeal_text' => $isReapplication ? $latestRejection->appeal_text : null,
        ];
    }
}
