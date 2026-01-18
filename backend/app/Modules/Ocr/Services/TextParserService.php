<?php

namespace App\Modules\Ocr\Services;

class TextParserService
{
    private array $cities;

    private array $nameFields;

    public function __construct()
    {
        $this->cities = config('ocr.cities', []);
        $this->nameFields = config('ocr.name_fields', ['name', 'nameEs', 'nameUk']);
    }

    public function parse(string $rawText): array
    {
        $phone = $this->extractPhone($rawText);
        $city = $this->extractCity($rawText);
        $name = $this->extractName($rawText, $phone, $city);

        $confidence = $this->calculateConfidence($name, $phone, $city);

        return [
            'name' => $name,
            'phone' => $phone,
            'city' => $city,
            'confidence' => $confidence,
        ];
    }

    private function extractPhone(string $text): ?string
    {
        // Ukrainian phones: +380 67 123 45 67 or 0671234567
        $ukrainianPattern = '/\+?38\s?0\s?\d{2}\s?\d{3}\s?\d{2}\s?\d{2}/';

        // Spanish phones: +34 612 345 678 or 612345678
        $spanishPattern = '/\+?34\s?\d{3}\s?\d{3}\s?\d{3}/';

        // Generic pattern for other formats
        $genericPattern = '/\+?\d{10,15}/';

        // Try Ukrainian format first (most common for this app)
        if (preg_match($ukrainianPattern, $text, $matches)) {
            return $this->normalizePhone($matches[0], 'UA');
        }

        // Try Spanish format
        if (preg_match($spanishPattern, $text, $matches)) {
            return $this->normalizePhone($matches[0], 'ES');
        }

        // Try generic format
        if (preg_match($genericPattern, $text, $matches)) {
            return $this->normalizePhone($matches[0]);
        }

        return null;
    }

    private function normalizePhone(string $phone, ?string $country = null): string
    {
        // Remove all non-digit characters except +
        $normalized = preg_replace('/[^\d+]/', '', $phone);

        // Add country code if missing
        if ($country === 'UA' && ! str_starts_with($normalized, '+380')) {
            if (str_starts_with($normalized, '380')) {
                $normalized = '+'.$normalized;
            } elseif (str_starts_with($normalized, '0')) {
                $normalized = '+38'.$normalized;
            }
        } elseif ($country === 'ES' && ! str_starts_with($normalized, '+34')) {
            if (str_starts_with($normalized, '34')) {
                $normalized = '+'.$normalized;
            } elseif (strlen($normalized) === 9) {
                $normalized = '+34'.$normalized;
            }
        }

        return $normalized;
    }

    private function extractCity(string $text): ?string
    {
        $textLower = mb_strtolower($text);

        // Check for exact match first
        $exactMatch = $this->findCityByExactMatch($textLower);
        if ($exactMatch !== null) {
            return $exactMatch;
        }

        // If no exact match, try fuzzy matching with levenshtein
        return $this->findCityByFuzzyMatch($text);
    }

    private function findCityByExactMatch(string $textLower): ?string
    {
        return $this->forEachCityName(function ($city, $cityName) use ($textLower) {
            if (mb_strpos($textLower, mb_strtolower($cityName)) !== false) {
                return $city['name'];
            }

            return null;
        });
    }

    private function findCityByFuzzyMatch(string $text): ?string
    {
        $lines = preg_split('/[\n\r]+/', $text);
        $bestMatch = null;
        $bestDistance = PHP_INT_MAX;

        foreach ($lines as $line) {
            $lineLower = mb_strtolower(trim($line));
            if (strlen($lineLower) < 3 || strlen($lineLower) > 50) {
                continue;
            }

            if (preg_match('/^\+?\d/', $lineLower)) {
                continue;
            }

            $this->forEachCityName(function ($city, $cityName) use ($lineLower, &$bestMatch, &$bestDistance) {
                $cityNameLower = mb_strtolower($cityName);
                $distance = levenshtein($lineLower, $cityNameLower);
                $threshold = max(2, (int) (strlen($cityNameLower) * 0.3));

                if ($distance < $threshold && $distance < $bestDistance) {
                    $bestDistance = $distance;
                    $bestMatch = $city['name'];
                }

                return null;
            });
        }

        return $bestMatch;
    }

    private function forEachCityName(callable $callback): mixed
    {
        foreach ($this->cities as $city) {
            foreach ($this->nameFields as $nameField) {
                $result = $callback($city, $city[$nameField]);
                if ($result !== null) {
                    return $result;
                }
            }
        }

        return null;
    }

    private function extractName(string $text, ?string $phone, ?string $city): ?string
    {
        $lines = preg_split('/[\n\r]+/', $text);
        $candidates = [];

        foreach ($lines as $line) {
            $line = trim($line);

            if ($this->isValidNameCandidate($line, $phone, $city)) {
                $candidates[] = $line;
            }
        }

        return $candidates[0] ?? null;
    }

    private function isValidNameCandidate(string $line, ?string $phone, ?string $city): bool
    {
        if (empty($line) || mb_strlen($line) < 3 || mb_strlen($line) > 100) {
            return false;
        }

        if ($this->looksLikePhoneNumber($line, $phone)) {
            return false;
        }

        if ($city && $this->lineIsCity($line, $city)) {
            return false;
        }

        if ($this->looksLikeAddress($line)) {
            return false;
        }

        if ($this->isCommonLabel($line)) {
            return false;
        }

        return (bool) preg_match('/^[\p{L}\s\.\-]+$/u', $line);
    }

    private function looksLikePhoneNumber(string $line, ?string $phone): bool
    {
        if (preg_match('/^\+?\d[\d\s\-]+$/', $line)) {
            return true;
        }

        if ($phone) {
            $lineNormalized = preg_replace('/\s/', '', $line);
            $phoneNormalized = preg_replace('/\s/', '', $phone);

            return str_contains($lineNormalized, $phoneNormalized);
        }

        return false;
    }

    private function looksLikeAddress(string $line): bool
    {
        return (bool) preg_match('/\d+\s*(,|$)/', $line);
    }

    private function isCommonLabel(string $line): bool
    {
        $skipWords = ['от:', 'кому:', 'from:', 'to:', 'получатель', 'отправитель', 'destinatario', 'remitente', 'адрес', 'address'];
        $lineLower = mb_strtolower($line);

        foreach ($skipWords as $word) {
            if (str_starts_with($lineLower, $word)) {
                return true;
            }
        }

        return false;
    }

    private function lineIsCity(string $line, string $city): bool
    {
        $lineLower = mb_strtolower(trim($line));

        foreach ($this->cities as $cityData) {
            if ($cityData['name'] !== $city) {
                continue;
            }

            foreach ($this->nameFields as $nameField) {
                if (mb_strtolower($cityData[$nameField]) === $lineLower) {
                    return true;
                }
            }
        }

        return false;
    }

    private function calculateConfidence(?string $name, ?string $phone, ?string $city): float
    {
        $score = 0;
        $total = 3;

        if ($name !== null && mb_strlen($name) >= 3) {
            $score++;
        }
        if ($phone !== null) {
            $score++;
        }
        if ($city !== null) {
            $score++;
        }

        return round($score / $total, 2);
    }
}
