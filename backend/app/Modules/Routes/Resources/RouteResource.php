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

            'departure_date' => $this->departure_date?->format('Y-m-d'),
            'estimated_arrival_date' => $this->estimated_arrival_date?->format('Y-m-d'),
            'actual_arrival_date' => $this->actual_arrival_date?->format('Y-m-d'),

            'status' => $this->status,
            'status_label' => $this->status?->label(),

            'vehicle_info' => $this->vehicle_info,
            'notes' => $this->notes,

            'packages_count' => $this->when(isset($this->packages_count), $this->packages_count),

            'schedules' => $this->whenLoaded('schedules', fn () => $this->schedules->map(fn ($schedule) => [
                'id' => $schedule->id,
                'departure_date' => $schedule->departure_date?->format('Y-m-d'),
                'estimated_arrival_date' => $schedule->estimated_arrival_date?->format('Y-m-d'),
                'status' => $schedule->status,
                'status_label' => $schedule->status?->label(),
            ])
            ),

            'transporter' => $this->whenLoaded('transporter', fn () => [
                'id' => $this->transporter->id,
                'name' => $this->transporter->name,
            ]),

            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
