<?php

namespace App\Shared\Enums;

enum RouteStatus: string
{
    case PLANNED = 'planned';
    case IN_PROGRESS = 'in_progress';
    case COMPLETED = 'completed';
    case CANCELLED = 'cancelled';

    public function label(): string
    {
        return match ($this) {
            self::PLANNED => 'Planificada',
            self::IN_PROGRESS => 'En progreso',
            self::COMPLETED => 'Completada',
            self::CANCELLED => 'Cancelada',
        };
    }

    public static function values(): array
    {
        return array_column(self::cases(), 'value');
    }
}
