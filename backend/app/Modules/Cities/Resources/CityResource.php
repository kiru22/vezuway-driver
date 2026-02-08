<?php

namespace App\Modules\Cities\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CityResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'name_local' => $this->name_local,
            'name_es' => $this->name_es,
            'name_uk' => $this->name_uk,
            'country_code' => $this->country_code,
            'admin1_name' => $this->admin1_name,
            'population' => $this->population,
            'latitude' => $this->latitude,
            'longitude' => $this->longitude,
        ];
    }
}
