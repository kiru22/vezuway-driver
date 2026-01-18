<?php

namespace App\Modules\Ocr\Services;

use Google\Cloud\Vision\V1\AnnotateImageRequest;
use Google\Cloud\Vision\V1\BatchAnnotateImagesRequest;
use Google\Cloud\Vision\V1\Client\ImageAnnotatorClient;
use Google\Cloud\Vision\V1\Feature;
use Google\Cloud\Vision\V1\Feature\Type;
use Google\Cloud\Vision\V1\Image;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Log;

class OcrService
{
    private ?ImageAnnotatorClient $client = null;

    public function extractText(UploadedFile $image): ?string
    {
        try {
            $client = $this->getClient();

            $imageContent = file_get_contents($image->getRealPath());

            $visionImage = (new Image)->setContent($imageContent);

            $feature = (new Feature)->setType(Type::TEXT_DETECTION);

            $annotateRequest = (new AnnotateImageRequest)
                ->setImage($visionImage)
                ->setFeatures([$feature]);

            $batchRequest = (new BatchAnnotateImagesRequest)
                ->setRequests([$annotateRequest]);

            $response = $client->batchAnnotateImages($batchRequest);
            $annotations = $response->getResponses()[0];

            if ($annotations->hasError()) {
                Log::error('Google Vision API error', [
                    'error' => $annotations->getError()->getMessage(),
                ]);

                return null;
            }

            $textAnnotations = $annotations->getTextAnnotations();

            if (count($textAnnotations) === 0) {
                return null;
            }

            // First annotation contains the full text
            return $textAnnotations[0]->getDescription();
        } catch (\Exception $e) {
            Log::error('OCR extraction failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return null;
        }
    }

    private function getClient(): ImageAnnotatorClient
    {
        if ($this->client === null) {
            $keyFilePath = config('services.google.cloud_vision_key_file');

            $options = [];
            if ($keyFilePath && file_exists($keyFilePath)) {
                $options['credentials'] = $keyFilePath;
            }

            $this->client = new ImageAnnotatorClient($options);
        }

        return $this->client;
    }

    public function __destruct()
    {
        if ($this->client !== null) {
            $this->client->close();
        }
    }
}
