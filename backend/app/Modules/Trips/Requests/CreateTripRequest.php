<?php

namespace App\Modules\Trips\Requests;

use Illuminate\Foundation\Http\FormRequest;

class CreateTripRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'route_id' => 'nullable|uuid|exists:routes,id',
            'origin_city' => 'required|string|max:100',
            'origin_country' => 'required|string|max:2',
            'destination_city' => 'required|string|max:100',
            'destination_country' => 'required|string|max:2',
            'departure_date' => 'required|date',
            'departure_time' => 'nullable|date_format:H:i',
            'estimated_arrival_date' => 'nullable|date|after_or_equal:departure_date',
            'vehicle_info' => 'nullable|array',
            'notes' => 'nullable|string|max:1000',
            'price_per_kg' => 'nullable|numeric|min:0|max:9999.99',
            'minimum_price' => 'nullable|numeric|min:0|max:9999.99',
            'price_multiplier' => 'nullable|numeric|min:0.1|max:10',
            'stops' => 'nullable|array',
            'stops.*.city' => 'required_with:stops|string|max:100',
            'stops.*.country' => 'required_with:stops|string|max:2',
            'stops.*.order' => 'nullable|integer|min:0',
        ];
    }
}
