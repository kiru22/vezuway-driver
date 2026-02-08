<?php

namespace App\Modules\Cities\Services;

use App\Modules\Cities\Models\City;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;
use ZipArchive;

class GeoNamesImportService
{
    private const GEONAMES_BASE_URL = 'https://download.geonames.org/export/dump/';

    private const UNLOCODE_CSV_URL = 'https://raw.githubusercontent.com/datasets/un-locode/main/data/code-list.csv';

    private const CHUNK_SIZE = 1000;

    /**
     * GeoNames TSV column indices for country files.
     */
    private const COL_GEONAME_ID = 0;

    private const COL_NAME = 1;

    private const COL_ASCII_NAME = 2;

    private const COL_FEATURE_CLASS = 6;

    private const COL_FEATURE_CODE = 7;

    private const COL_COUNTRY_CODE = 8;

    private const COL_ADMIN1_CODE = 10;

    private const COL_POPULATION = 14;

    private const COL_LATITUDE = 4;

    private const COL_LONGITUDE = 5;

    /**
     * AlternateNames TSV column indices.
     */
    private const ALT_GEONAME_ID = 1;

    private const ALT_LANG = 2;

    private const ALT_NAME = 3;

    private const ALT_IS_PREFERRED = 4;

    /** @var array<int, array<string, string|null>> */
    private array $translations = [];

    private const TRANSLATION_LANGS = ['es', 'uk', 'pl', 'de'];

    /** @var array<string, array<string, string>> Admin1 code to name mapping */
    private array $admin1Names = [];

    /** @var array<string, array<string, string>> Country code → [lowercase name → 3-char location code] */
    private array $unLocodes = [];

    private string $tempDir;

    public function __construct()
    {
        $this->tempDir = storage_path('app/geonames');
    }

    /**
     * @param  array<string>  $countries
     */
    public function import(
        array $countries,
        int $minPopulation,
        callable $onProgress
    ): int {
        if (! is_dir($this->tempDir)) {
            mkdir($this->tempDir, 0755, true);
        }

        $geonameIds = $this->collectGeonameIds($countries, $minPopulation, $onProgress);

        if (empty($geonameIds)) {
            $onProgress('No cities found matching criteria.');

            return 0;
        }

        $this->loadAdmin1Names($countries, $onProgress);
        $this->loadTranslations($geonameIds, $onProgress);

        $total = $this->importCountries($countries, $minPopulation, $onProgress);

        $this->generateTrackingCodes($onProgress);

        $this->cleanup();

        return $total;
    }

    /**
     * First pass: collect all relevant geoname_ids so we can filter translations.
     *
     * @param  array<string>  $countries
     * @return array<int>
     */
    private function collectGeonameIds(array $countries, int $minPopulation, callable $onProgress): array
    {
        $ids = [];

        foreach ($countries as $country) {
            $filePath = $this->downloadCountryFile($country, $onProgress);
            if (! $filePath) {
                continue;
            }

            $handle = fopen($filePath, 'r');
            if (! $handle) {
                continue;
            }

            while (($line = fgets($handle)) !== false) {
                $fields = explode("\t", $line);
                if (count($fields) < 15) {
                    continue;
                }

                if (($fields[self::COL_FEATURE_CLASS] ?? '') !== 'P') {
                    continue;
                }

                $population = (int) ($fields[self::COL_POPULATION] ?? 0);
                if ($population < $minPopulation) {
                    continue;
                }

                $ids[] = (int) $fields[self::COL_GEONAME_ID];
            }

            fclose($handle);
        }

        $onProgress('Collected '.count($ids).' geoname IDs for translation lookup.');

        return $ids;
    }

    /**
     * @param  array<string>  $countries
     */
    private function loadAdmin1Names(array $countries, callable $onProgress): void
    {
        foreach ($countries as $country) {
            $this->admin1Names[$country] = [];
        }

        $filePath = $this->downloadFile('admin1CodesASCII.txt', $onProgress);
        if (! $filePath) {
            return;
        }

        $handle = fopen($filePath, 'r');
        if (! $handle) {
            return;
        }

        $countriesSet = array_flip($countries);

        while (($line = fgets($handle)) !== false) {
            $fields = explode("\t", trim($line));
            if (count($fields) < 2) {
                continue;
            }

            // Format: CC.ADMIN1_CODE\tName\tAsciiName\tGeonameId
            $codeParts = explode('.', $fields[0]);
            if (count($codeParts) !== 2) {
                continue;
            }

            $cc = $codeParts[0];
            $admin1Code = $codeParts[1];

            if (isset($countriesSet[$cc])) {
                $this->admin1Names[$cc][$admin1Code] = $fields[1];
            }
        }

        fclose($handle);
        $onProgress('Loaded admin1 names.');
    }

    /**
     * @param  array<int>  $geonameIds
     */
    private function loadTranslations(array $geonameIds, callable $onProgress): void
    {
        $onProgress('Downloading alternate names (this may take a while)...');

        $filePath = $this->downloadFile('alternateNamesV2.zip', $onProgress);
        if (! $filePath) {
            $onProgress('Could not download alternateNames. Proceeding without translations.');

            return;
        }

        $extractedPath = $this->tempDir.'/alternateNamesV2.txt';
        if (! file_exists($extractedPath)) {
            $zip = new ZipArchive;
            if ($zip->open($filePath) === true) {
                $zip->extractTo($this->tempDir);
                $zip->close();
            }
        }

        if (! file_exists($extractedPath)) {
            $onProgress('Could not extract alternateNames. Proceeding without translations.');

            return;
        }

        $idsSet = array_flip($geonameIds);

        $handle = fopen($extractedPath, 'r');
        if (! $handle) {
            return;
        }

        $count = 0;
        while (($line = fgets($handle)) !== false) {
            $fields = explode("\t", $line);
            if (count($fields) < 5) {
                continue;
            }

            $geonameId = (int) $fields[self::ALT_GEONAME_ID];
            if (! isset($idsSet[$geonameId])) {
                continue;
            }

            $lang = trim($fields[self::ALT_LANG] ?? '');
            if (! in_array($lang, self::TRANSLATION_LANGS, true)) {
                continue;
            }

            $name = trim($fields[self::ALT_NAME] ?? '');
            if ($name === '') {
                continue;
            }

            $isPreferred = (int) ($fields[self::ALT_IS_PREFERRED] ?? 0);

            if (! isset($this->translations[$geonameId])) {
                $this->translations[$geonameId] = array_fill_keys(self::TRANSLATION_LANGS, null);
            }

            // Only overwrite if preferred or no translation yet
            if ($isPreferred || $this->translations[$geonameId][$lang] === null) {
                $this->translations[$geonameId][$lang] = $name;
            }

            $count++;
        }

        fclose($handle);
        $onProgress("Loaded {$count} translations (es/uk).");
    }

    /**
     * @param  array<string>  $countries
     */
    private function importCountries(array $countries, int $minPopulation, callable $onProgress): int
    {
        $total = 0;

        foreach ($countries as $country) {
            $filePath = $this->downloadCountryFile($country, $onProgress);
            if (! $filePath) {
                continue;
            }

            $count = $this->importCountryFile($filePath, $country, $minPopulation, $onProgress);
            $total += $count;
            $onProgress("Imported {$count} cities for {$country}.");
        }

        return $total;
    }

    private function importCountryFile(string $filePath, string $countryCode, int $minPopulation, callable $onProgress): int
    {
        $handle = fopen($filePath, 'r');
        if (! $handle) {
            return 0;
        }

        $batch = [];
        $count = 0;

        while (($line = fgets($handle)) !== false) {
            $fields = explode("\t", $line);
            if (count($fields) < 15) {
                continue;
            }

            if (($fields[self::COL_FEATURE_CLASS] ?? '') !== 'P') {
                continue;
            }

            $population = (int) ($fields[self::COL_POPULATION] ?? 0);
            if ($population < $minPopulation) {
                continue;
            }

            $geonameId = (int) $fields[self::COL_GEONAME_ID];
            $name = trim($fields[self::COL_ASCII_NAME] ?? $fields[self::COL_NAME] ?? '');
            $nameLocal = trim($fields[self::COL_NAME] ?? $name);
            $admin1Code = trim($fields[self::COL_ADMIN1_CODE] ?? '');

            $nameEs = $this->translations[$geonameId]['es'] ?? null;
            $nameUk = $this->translations[$geonameId]['uk'] ?? null;
            $admin1Name = $this->admin1Names[$countryCode][$admin1Code] ?? null;

            // Collect all name variants for search_text (including local language)
            $extraNames = [];
            foreach (self::TRANSLATION_LANGS as $lang) {
                $translated = $this->translations[$geonameId][$lang] ?? null;
                if ($translated !== null) {
                    $extraNames[] = $translated;
                }
            }

            $searchText = City::buildSearchText($name, $nameLocal, $nameEs, $nameUk, $extraNames);

            $batch[] = [
                'id' => Str::uuid()->toString(),
                'geoname_id' => $geonameId,
                'name' => $name,
                'name_local' => $nameLocal,
                'name_es' => $nameEs,
                'name_uk' => $nameUk,
                'country_code' => $countryCode,
                'admin1_name' => $admin1Name,
                'latitude' => (float) ($fields[self::COL_LATITUDE] ?? 0),
                'longitude' => (float) ($fields[self::COL_LONGITUDE] ?? 0),
                'population' => $population,
                'feature_code' => trim($fields[self::COL_FEATURE_CODE] ?? ''),
                'search_text' => $searchText,
                'created_at' => now(),
                'updated_at' => now(),
            ];

            if (count($batch) >= self::CHUNK_SIZE) {
                $this->upsertBatch($batch);
                $count += count($batch);
                $batch = [];

                if ($count % 5000 === 0) {
                    $onProgress("  {$countryCode}: processed {$count} cities...");
                }
            }
        }

        if (! empty($batch)) {
            $this->upsertBatch($batch);
            $count += count($batch);
        }

        fclose($handle);

        return $count;
    }

    /**
     * @param  array<array<string, mixed>>  $batch
     */
    private function upsertBatch(array $batch): void
    {
        DB::table('cities')->upsert(
            $batch,
            ['geoname_id'],
            ['name', 'name_local', 'name_es', 'name_uk', 'country_code', 'admin1_name', 'latitude', 'longitude', 'population', 'feature_code', 'search_text', 'updated_at']
        );
    }

    private function downloadCountryFile(string $countryCode, callable $onProgress): ?string
    {
        $zipPath = $this->tempDir."/{$countryCode}.zip";
        $txtPath = $this->tempDir."/{$countryCode}.txt";

        if (file_exists($txtPath)) {
            return $txtPath;
        }

        if (! file_exists($zipPath)) {
            $onProgress("Downloading {$countryCode}.zip...");
            $url = self::GEONAMES_BASE_URL."{$countryCode}.zip";

            $response = Http::withOptions(['sink' => $zipPath, 'timeout' => 120])->get($url);
            if (! $response->successful()) {
                $onProgress("Failed to download {$countryCode}.zip (HTTP {$response->status()})");

                return null;
            }
        }

        $zip = new ZipArchive;
        if ($zip->open($zipPath) === true) {
            $zip->extractTo($this->tempDir);
            $zip->close();
        }

        return file_exists($txtPath) ? $txtPath : null;
    }

    private function downloadFile(string $filename, callable $onProgress): ?string
    {
        $localPath = $this->tempDir.'/'.$filename;

        if (file_exists($localPath)) {
            return $localPath;
        }

        $onProgress("Downloading {$filename}...");
        $url = self::GEONAMES_BASE_URL.$filename;

        $response = Http::withOptions(['sink' => $localPath, 'timeout' => 300])->get($url);
        if (! $response->successful()) {
            $onProgress("Failed to download {$filename} (HTTP {$response->status()})");

            return null;
        }

        return $localPath;
    }

    /**
     * Generate tracking codes using UN/LOCODE standard.
     * Fallback: first 3 ASCII letters of the city name.
     */
    private function generateTrackingCodes(callable $onProgress): void
    {
        $onProgress('Generating tracking codes (UN/LOCODE)...');

        $countries = DB::table('cities')
            ->whereNull('tracking_code')
            ->distinct()
            ->pluck('country_code')
            ->all();

        $this->loadUnLocodes($countries, $onProgress);

        $batch = [];
        $count = 0;

        foreach (DB::table('cities')->whereNull('tracking_code')->orderByDesc('population')->select(['id', 'name', 'country_code'])->cursor() as $city) {
            $code = $this->resolveUnLocode($city->country_code, $city->name);
            $batch[$city->id] = $code;
            $count++;

            if (count($batch) >= self::CHUNK_SIZE) {
                $this->updateTrackingCodeBatch($batch);
                $batch = [];

                if ($count % 10000 === 0) {
                    $onProgress("  Generated {$count} tracking codes...");
                }
            }
        }

        if (! empty($batch)) {
            $this->updateTrackingCodeBatch($batch);
        }

        $onProgress("Generated {$count} tracking codes.");
    }

    /**
     * Download and parse UN/LOCODE CSV into a lookup map.
     *
     * @param  array<string>  $countries
     */
    private function loadUnLocodes(array $countries, callable $onProgress): void
    {
        $csvPath = $this->tempDir.'/un-locode.csv';

        if (! file_exists($csvPath)) {
            $onProgress('Downloading UN/LOCODE data...');
            $response = Http::withOptions(['sink' => $csvPath, 'timeout' => 120])->get(self::UNLOCODE_CSV_URL);
            if (! $response->successful()) {
                $onProgress('Failed to download UN/LOCODE. Using fallback codes only.');

                return;
            }
        }

        $statusPriority = ['AI' => 4, 'AA' => 3, 'RL' => 2, 'RQ' => 1];
        $priorities = [];

        $countriesSet = array_flip(array_map('strtoupper', $countries));
        $handle = fopen($csvPath, 'r');
        if (! $handle) {
            return;
        }

        fgetcsv($handle);

        $count = 0;
        while (($row = fgetcsv($handle)) !== false) {
            if (count($row) < 7) {
                continue;
            }

            $cc = strtoupper(trim($row[1] ?? ''));
            if (! isset($countriesSet[$cc])) {
                continue;
            }

            $locationCode = strtoupper(trim($row[2] ?? ''));
            if (strlen($locationCode) !== 3) {
                continue;
            }

            $status = trim($row[6] ?? '');
            $priority = $statusPriority[$status] ?? 0;

            $ccLower = strtolower($cc);
            if (! isset($this->unLocodes[$ccLower])) {
                $this->unLocodes[$ccLower] = [];
                $priorities[$ccLower] = [];
            }

            $names = array_unique(array_filter([
                $this->normalizeForMatch(trim($row[3] ?? '')),
                $this->normalizeForMatch(trim($row[4] ?? '')),
            ]));

            foreach ($names as $key) {
                if ($key === '') {
                    continue;
                }

                if ($priority >= ($priorities[$ccLower][$key] ?? -1)) {
                    $this->unLocodes[$ccLower][$key] = $locationCode;
                    $priorities[$ccLower][$key] = $priority;
                    $count++;
                }
            }
        }

        fclose($handle);
        $onProgress("Loaded {$count} UN/LOCODE entries for ".implode(', ', $countries).'.');
    }

    /**
     * Resolve a city's tracking code: UN/LOCODE match or 3-letter ASCII fallback.
     */
    private function resolveUnLocode(string $countryCode, string $name): string
    {
        $ccLower = strtolower($countryCode);
        $key = $this->normalizeForMatch($name);

        if ($key !== '' && isset($this->unLocodes[$ccLower][$key])) {
            return $this->unLocodes[$ccLower][$key];
        }

        $transliterated = iconv('UTF-8', 'ASCII//TRANSLIT//IGNORE', $name) ?: $name;
        $letters = strtoupper(preg_replace('/[^A-Z]/', '', strtoupper($transliterated)));

        return substr(str_pad($letters, 3, 'X'), 0, 3);
    }

    /**
     * Normalize a city name for UN/LOCODE matching:
     * strip apostrophes, parenthetical suffixes, lowercase.
     */
    private function normalizeForMatch(string $name): string
    {
        $name = preg_replace('/\s*\(.*\)/', '', $name);
        $name = str_replace(["'", "\u{2019}", "`"], '', $name);

        return strtolower(trim($name));
    }

    /**
     * Bulk update tracking codes using a single query with CASE WHEN.
     *
     * @param  array<string, string>  $batch  id => tracking_code
     */
    private function updateTrackingCodeBatch(array $batch): void
    {
        if (empty($batch)) {
            return;
        }

        $cases = [];
        $bindings = [];

        foreach ($batch as $id => $code) {
            $cases[] = 'WHEN id = ? THEN ?';
            $bindings[] = $id;
            $bindings[] = $code;
        }

        $ids = array_keys($batch);
        $placeholders = implode(',', array_fill(0, count($ids), '?'));
        $bindings = array_merge($bindings, $ids);

        $sql = 'UPDATE cities SET tracking_code = CASE '.implode(' ', $cases)." END, updated_at = NOW() WHERE id IN ({$placeholders})";

        DB::statement($sql, $bindings);
    }

    private function cleanup(): void
    {
        // Keep downloaded files for re-runs, they can be manually deleted
    }
}
