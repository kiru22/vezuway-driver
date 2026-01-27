<?php

namespace App\Modules\Packages\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PackageResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'tracking_code' => $this->tracking_code,
            'transporter_id' => $this->transporter_id,
            'route_id' => $this->route_id,
            'trip_id' => $this->trip_id,
            'sender_contact_id' => $this->sender_contact_id,
            'receiver_contact_id' => $this->receiver_contact_id,

            'sender' => [
                'name' => $this->sender_name,
                'phone' => $this->sender_phone,
                'address' => $this->sender_address,
                'city' => $this->sender_city,
                'country' => $this->sender_country,
                'latitude' => $this->sender_latitude,
                'longitude' => $this->sender_longitude,
            ],

            'receiver' => [
                'name' => $this->receiver_name,
                'phone' => $this->receiver_phone,
                'address' => $this->receiver_address,
                'city' => $this->receiver_city,
                'country' => $this->receiver_country,
                'latitude' => $this->receiver_latitude,
                'longitude' => $this->receiver_longitude,
            ],

            'dimensions' => [
                'weight_kg' => $this->weight_kg,
                'length_cm' => $this->length_cm,
                'width_cm' => $this->width_cm,
                'height_cm' => $this->height_cm,
            ],

            'quantity' => $this->quantity ?? 1,

            'description' => $this->description,
            'declared_value' => $this->declared_value,
            'status' => $this->status,
            'status_label' => $this->status?->label(),

            'ocr' => [
                'scanned_image_url' => $this->scanned_image_url,
                'confidence' => $this->ocr_confidence,
            ],

            'notes' => $this->notes,
            'metadata' => $this->metadata,

            'route' => $this->whenLoaded('route', fn () => [
                'id' => $this->route->id,
                'origin' => $this->route->origin_city.', '.$this->route->origin_country,
                'destination' => $this->route->destination_city.', '.$this->route->destination_country,
                'departure_date' => $this->route->departure_date->format('Y-m-d'),
            ]),

            'trip' => $this->whenLoaded('trip', fn () => [
                'id' => $this->trip->id,
                'origin_city' => $this->trip->origin_city,
                'origin_country' => $this->trip->origin_country,
                'destination_city' => $this->trip->destination_city,
                'destination_country' => $this->trip->destination_country,
                'departure_date' => $this->trip->departure_date?->format('Y-m-d'),
                'status' => $this->trip->status,
            ]),

            'transporter' => $this->whenLoaded('transporter', fn () => [
                'id' => $this->transporter->id,
                'name' => $this->transporter->name,
            ]),

            'sender_contact' => $this->whenLoaded('senderContact', fn () => [
                'id' => $this->senderContact->id,
                'name' => $this->senderContact->name,
                'email' => $this->senderContact->email,
                'phone' => $this->senderContact->phone,
                'total_packages' => $this->senderContact->total_packages,
                'is_verified' => $this->senderContact->is_verified,
            ]),

            'receiver_contact' => $this->whenLoaded('receiverContact', fn () => [
                'id' => $this->receiverContact->id,
                'name' => $this->receiverContact->name,
                'email' => $this->receiverContact->email,
                'phone' => $this->receiverContact->phone,
                'total_packages' => $this->receiverContact->total_packages,
                'is_verified' => $this->receiverContact->is_verified,
            ]),

            'status_history' => $this->whenLoaded('statusHistory'),

            'images' => $this->whenLoaded('media', fn () => $this->getMedia('images')->map(fn ($media) => [
                'id' => $media->id,
                'url' => $media->getUrl(),
                'thumb_url' => $media->getUrl('thumb'),
            ])->toArray()),

            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
