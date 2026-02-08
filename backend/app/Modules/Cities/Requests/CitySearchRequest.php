<?php

namespace App\Modules\Cities\Requests;

use Illuminate\Foundation\Http\FormRequest;

class CitySearchRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'q' => 'nullable|string|max:200',
            'countries' => 'nullable|string|max:20',
            'limit' => 'nullable|integer|min:1|max:50',
        ];
    }
}
