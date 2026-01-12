<?php

namespace App\Modules\Auth\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateAvatarRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'avatar' => 'required|image|mimes:jpeg,png,webp|max:5120',
        ];
    }

    public function messages(): array
    {
        return [
            'avatar.required' => 'La imagen es requerida.',
            'avatar.image' => 'El archivo debe ser una imagen.',
            'avatar.mimes' => 'La imagen debe ser JPEG, PNG o WebP.',
            'avatar.max' => 'La imagen no puede superar 5MB.',
        ];
    }
}
