<?php

namespace App\Modules\Ocr\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ScanImageRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'image' => 'required|image|mimes:jpeg,png,webp,heic|max:10240',
        ];
    }

    public function messages(): array
    {
        return [
            'image.required' => 'La imagen es requerida.',
            'image.image' => 'El archivo debe ser una imagen.',
            'image.mimes' => 'La imagen debe ser JPEG, PNG, WebP o HEIC.',
            'image.max' => 'La imagen no puede superar 10MB.',
        ];
    }
}
