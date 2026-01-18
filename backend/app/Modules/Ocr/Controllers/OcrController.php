<?php

namespace App\Modules\Ocr\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Ocr\Requests\ScanImageRequest;
use App\Modules\Ocr\Services\OcrService;
use App\Modules\Ocr\Services\TextParserService;
use Illuminate\Http\JsonResponse;

class OcrController extends Controller
{
    public function __construct(
        private OcrService $ocrService,
        private TextParserService $parserService,
    ) {}

    public function scan(ScanImageRequest $request): JsonResponse
    {
        $image = $request->file('image');
        $rawText = $this->ocrService->extractText($image);

        $parsed = $rawText !== null
            ? $this->parserService->parse($rawText)
            : $this->emptyParsedResult();

        return response()->json([
            'raw_text' => $rawText,
            'parsed' => [
                'name' => $parsed['name'],
                'phone' => $parsed['phone'],
                'city' => $parsed['city'],
            ],
            'confidence' => $parsed['confidence'],
            'message' => $rawText === null ? 'No se pudo extraer texto de la imagen.' : null,
        ]);
    }

    private function emptyParsedResult(): array
    {
        return ['name' => null, 'phone' => null, 'city' => null, 'confidence' => 0];
    }
}
