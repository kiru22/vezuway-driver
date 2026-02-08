<?php

namespace App\Modules\Packages\Services;

use App\Modules\Cities\Models\City;
use App\Modules\Packages\Models\Package;
use App\Modules\Trips\Models\Trip;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class TrackingCodeService
{
    /**
     * Generate a tracking code for a package.
     *
     * Format: {CityCode}{TripSuffix}-{MMDD}-{SeqNum}
     * Example: VL-0207-01, VL2-0207-01
     */
    public function generate(?string $receiverCity, ?string $tripId): string
    {
        $cityCode = $this->resolveCityCode($receiverCity);

        if (! $cityCode) {
            return $this->generateFallbackCode();
        }

        $date = $this->resolveDate($tripId);
        $dateStr = $date->format('md');

        return DB::transaction(function () use ($cityCode, $tripId, $date, $dateStr) {
            $tripSuffix = $this->resolveTripSuffix($cityCode, $tripId, $date);
            $prefix = $cityCode.$tripSuffix;

            $seqNum = $this->getNextSequenceNumber($prefix, $dateStr);

            return sprintf('%s-%s-%02d', $prefix, $dateStr, $seqNum);
        });
    }

    /**
     * Resolve city name to tracking code by searching the cities table
     * across all name variants (name, name_local, name_es, name_uk).
     */
    public function resolveCityCode(?string $cityName): ?string
    {
        if (empty($cityName)) {
            return null;
        }

        $normalized = mb_strtolower(trim($cityName));

        return City::whereNotNull('tracking_code')
            ->where(function ($q) use ($normalized) {
                $q->whereRaw('LOWER(name) = ?', [$normalized])
                    ->orWhereRaw('LOWER(name_local) = ?', [$normalized])
                    ->orWhereRaw('LOWER(name_es) = ?', [$normalized])
                    ->orWhereRaw('LOWER(name_uk) = ?', [$normalized]);
            })
            ->orderByDesc('population')
            ->value('tracking_code');
    }

    /**
     * Resolve the date to use: trip's departure_date or today.
     */
    public function resolveDate(?string $tripId): Carbon
    {
        if ($tripId) {
            $trip = Trip::find($tripId);
            if ($trip?->departure_date) {
                return $trip->departure_date;
            }
        }

        return Carbon::today();
    }

    /**
     * Determine the trip suffix for a given city, trip, and date.
     *
     * - No suffix for the first trip of the day
     * - "2" for the second trip, "3" for the third, etc.
     * - No suffix when there's no trip_id
     */
    public function resolveTripSuffix(string $cityCode, ?string $tripId, Carbon $date): string
    {
        if (! $tripId) {
            return '';
        }

        $dateStr = $date->format('md');
        $pattern = $cityCode.'%-'.$dateStr.'-%';

        // Check if this trip already has packages with the new format
        $existingFromThisTrip = Package::where('trip_id', $tripId)
            ->where('tracking_code', 'like', $pattern)
            ->where('tracking_code', 'not like', 'PKG-%')
            ->lockForUpdate()
            ->first();

        if ($existingFromThisTrip) {
            // Reuse the same prefix from this trip's existing packages
            return $this->extractTripSuffix($existingFromThisTrip->tracking_code, $cityCode);
        }

        // Get distinct trip_ids that already have packages with codes for this city+date
        // (separate query + PHP count because PG doesn't allow FOR UPDATE with aggregates)
        $existingTripIds = Package::where('tracking_code', 'like', $pattern)
            ->where('tracking_code', 'not like', 'PKG-%')
            ->where('trip_id', '!=', $tripId)
            ->lockForUpdate()
            ->pluck('trip_id')
            ->unique()
            ->count();

        // Also check packages without trip_id (they count as one "group")
        $hasNoTripPackages = Package::where('tracking_code', 'like', $pattern)
            ->where('tracking_code', 'not like', 'PKG-%')
            ->whereNull('trip_id')
            ->lockForUpdate()
            ->exists();

        $totalGroups = $existingTripIds + ($hasNoTripPackages ? 1 : 0);

        if ($totalGroups === 0) {
            return '';
        }

        return (string) ($totalGroups + 1);
    }

    /**
     * Generate fallback code when no city is available.
     */
    public function generateFallbackCode(): string
    {
        do {
            $code = 'PKG-'.strtoupper(Str::random(8));
        } while (Package::where('tracking_code', $code)->exists());

        return $code;
    }

    /**
     * Generate a unique public ID (PKG-XXXXXXXX, alphanumeric uppercase).
     */
    public function generatePublicId(): string
    {
        do {
            $chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
            $id = '';
            for ($i = 0; $i < 8; $i++) {
                $id .= $chars[random_int(0, 35)];
            }
            $publicId = 'PKG-'.$id;
        } while (Package::where('public_id', $publicId)->exists());

        return $publicId;
    }

    /**
     * Get the next sequence number for a given prefix and date.
     */
    private function getNextSequenceNumber(string $prefix, string $dateStr): int
    {
        $pattern = $prefix.'-'.$dateStr.'-%';

        $lastCode = Package::where('tracking_code', 'like', $pattern)
            ->where('tracking_code', 'not like', 'PKG-%')
            ->lockForUpdate()
            ->orderByRaw("CAST(SUBSTRING(tracking_code FROM '\\d+$') AS INTEGER) DESC")
            ->value('tracking_code');

        if (! $lastCode) {
            return 1;
        }

        // Extract the sequence number from the end: "VL-0207-15" → 15
        $parts = explode('-', $lastCode);
        $lastSeq = (int) end($parts);

        return $lastSeq + 1;
    }

    /**
     * Extract trip suffix from an existing tracking code.
     * "VL2-0207-01" → "2", "VL-0207-01" → ""
     */
    private function extractTripSuffix(string $trackingCode, string $cityCode): string
    {
        $firstPart = explode('-', $trackingCode)[0]; // "VL2" or "VL"

        return substr($firstPart, strlen($cityCode)); // "2" or ""
    }
}
