<?php

namespace App\Modules\Cities\Models;

use App\Shared\Traits\HasUuid;
use Database\Factories\CityFactory;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class City extends Model
{
    use HasFactory, HasUuid;

    protected static function newFactory(): CityFactory
    {
        return CityFactory::new();
    }

    protected $fillable = [
        'geoname_id',
        'name',
        'name_local',
        'name_es',
        'name_uk',
        'country_code',
        'admin1_name',
        'latitude',
        'longitude',
        'population',
        'feature_code',
        'search_text',
        'tracking_code',
    ];

    protected $casts = [
        'geoname_id' => 'integer',
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
        'population' => 'integer',
    ];

    /**
     * Search cities using trigram similarity for queries >= 3 chars,
     * or ILIKE prefix matching for shorter queries.
     */
    public function scopeSearch(Builder $query, string $term): void
    {
        $term = trim($term);

        if (mb_strlen($term) < 1) {
            $query->whereRaw('1 = 0');

            return;
        }

        $termLower = mb_strtolower($term);

        if (mb_strlen($term) <= 2) {
            $query->whereRaw('search_text ILIKE ?', [$termLower.'%']);
        } else {
            $query->whereRaw('word_similarity(?, search_text) > 0.3', [$termLower])
                ->orderByRaw('word_similarity(?, search_text) DESC', [$termLower]);
        }
    }

    public function scopeForCountries(Builder $query, array $codes): void
    {
        $query->whereIn('country_code', $codes);
    }

    /**
     * Build the search_text field from all name variants.
     *
     * @param  array<string>  $extraNames
     */
    public static function buildSearchText(string $name, string $nameLocal, ?string $nameEs, ?string $nameUk, array $extraNames = []): string
    {
        $parts = array_filter([
            mb_strtolower($name),
            mb_strtolower($nameLocal),
            $nameEs ? mb_strtolower($nameEs) : null,
            $nameUk ? mb_strtolower($nameUk) : null,
            ...array_map('mb_strtolower', $extraNames),
        ]);

        return implode(' ', array_unique($parts));
    }
}
