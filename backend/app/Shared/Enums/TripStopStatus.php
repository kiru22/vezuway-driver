<?php

namespace App\Shared\Enums;

enum TripStopStatus: string
{
    case PENDING = 'pending';
    case ARRIVED = 'arrived';
    case DEPARTED = 'departed';
    case SKIPPED = 'skipped';

    public function label(): string
    {
        return match ($this) {
            self::PENDING => 'Pendiente',
            self::ARRIVED => 'Llegado',
            self::DEPARTED => 'Partió',
            self::SKIPPED => 'Omitido',
        };
    }

    public static function values(): array
    {
        return array_column(self::cases(), 'value');
    }
}
