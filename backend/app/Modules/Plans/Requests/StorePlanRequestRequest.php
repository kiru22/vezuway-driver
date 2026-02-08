<?php

namespace App\Modules\Plans\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StorePlanRequestRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'plan_key' => ['required', 'string', 'in:basic,pro,premium'],
            'plan_name' => ['required', 'string', 'max:50'],
            'plan_price' => ['required', 'integer', 'min:0'],
        ];
    }
}
