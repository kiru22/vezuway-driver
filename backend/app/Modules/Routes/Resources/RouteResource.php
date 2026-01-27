<?php

namespace App\Modules\Routes\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RouteResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'transporter_id' => $this->transporter_id,

            'name' => $this->name,
            'display_name' => $this->display_name,
            'description' => $this->description,
            'is_active' => $this->is_active,
            'estimated_duration_hours' => $this->estimated_duration_hours,

            'origin' => [
                'city' => $this->origin_city,
                'country' => $this->origin_country,
                'latitude' => $this->origin_latitude,
                'longitude' => $this->origin_longitude,
            ],

            'destination' => [
                'city' => $this->destination_city,
                'country' => $this->destination_country,
                'latitude' => $this->destination_latitude,
                'longitude' => $this->destination_longitude,
            ],

            'vehicle_info' => $this->vehicle_info,
            'notes' => $this->notes,

            'pricing' => [
                'price_per_kg' => $this->price_per_kg,
                'minimum_price' => $this->minimum_price,
                'multiplier' => $this->price_multiplier,
            ],

            'stops' => $this->whenLoaded('stops', fn () => $this->stops->map(fn ($stop) => [
                'id' => $stop->id,
                'city' => $stop->city,
                'country' => $stop->country,
                'order' => $stop->order,
            ])),

            'trips_count' => $this->when(isset($this->trips_count), $this->trips_count),

            'transporter' => $this->whenLoaded('transporter', fn () => [
                'id' => $this->transporter->id,
                'name' => $this->transporter->name,
            ]),

            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
