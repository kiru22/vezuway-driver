<?php

namespace App\Modules\Trips\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TripResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'route_id' => $this->route_id,
            'transporter_id' => $this->transporter_id,

            'origin' => [
                'city' => $this->origin_city,
                'country' => $this->origin_country,
            ],

            'destination' => [
                'city' => $this->destination_city,
                'country' => $this->destination_country,
            ],

            'departure_date' => $this->departure_date?->format('Y-m-d'),
            'departure_time' => $this->departure_time?->format('H:i'),
            'estimated_arrival_date' => $this->estimated_arrival_date?->format('Y-m-d'),
            'actual_arrival_date' => $this->actual_arrival_date?->format('Y-m-d'),

            'status' => $this->status,
            'status_label' => $this->status?->label(),

            'vehicle_info' => $this->vehicle_info,
            'notes' => $this->notes,

            'pricing' => [
                'price_per_kg' => $this->price_per_kg,
                'minimum_price' => $this->minimum_price,
                'multiplier' => $this->price_multiplier,
                'currency' => $this->currency ?? 'EUR',
            ],

            'stops' => $this->whenLoaded('stops', fn () => $this->stops->map(fn ($stop) => [
                'id' => $stop->id,
                'city' => $stop->city,
                'country' => $stop->country,
                'order' => $stop->order,
                'status' => $stop->status,
                'status_label' => $stop->status?->label(),
                'arrived_at' => $stop->arrived_at?->toISOString(),
                'departed_at' => $stop->departed_at?->toISOString(),
            ])),

            'packages_count' => $this->when(isset($this->packages_count), $this->packages_count),

            'route' => $this->whenLoaded('route', fn () => [
                'id' => $this->route->id,
                'name' => $this->route->name ?? "{$this->route->origin_city} - {$this->route->destination_city}",
            ]),

            'transporter' => $this->whenLoaded('transporter', fn () => [
                'id' => $this->transporter->id,
                'name' => $this->transporter->name,
            ]),

            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
