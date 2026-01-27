<?php

namespace App\Modules\Trips\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateTripRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'origin_city' => 'sometimes|string|max:100',
            'origin_country' => 'sometimes|string|max:2',
            'destination_city' => 'sometimes|string|max:100',
            'destination_country' => 'sometimes|string|max:2',
            'departure_date' => 'sometimes|date',
            'departure_time' => 'nullable|date_format:H:i',
            'estimated_arrival_date' => 'nullable|date',
            'actual_arrival_date' => 'nullable|date',
            'vehicle_info' => 'nullable|array',
            'notes' => 'nullable|string|max:1000',
            'price_per_kg' => 'nullable|numeric|min:0|max:9999.99',
            'minimum_price' => 'nullable|numeric|min:0|max:9999.99',
            'price_multiplier' => 'nullable|numeric|min:0.1|max:10',
        ];
    }
}
