<?php

namespace App\Shared\Enums;

enum PackageStatus: string
{
    case PENDING = 'pending';
    case PICKED_UP = 'picked_up';
    case IN_TRANSIT = 'in_transit';
    case CUSTOMS = 'customs';
    case CUSTOMS_CLEARED = 'customs_cleared';
    case OUT_FOR_DELIVERY = 'out_for_delivery';
    case DELIVERED = 'delivered';
    case RETURNED = 'returned';
    case CANCELLED = 'cancelled';
    case DELAYED = 'delayed';

    public function label(): string
    {
        return match ($this) {
            self::PENDING => 'Pendiente',
            self::PICKED_UP => 'Recogido',
            self::IN_TRANSIT => 'En tránsito',
            self::CUSTOMS => 'En aduanas',
            self::CUSTOMS_CLEARED => 'Aduanas superado',
            self::OUT_FOR_DELIVERY => 'En reparto',
            self::DELIVERED => 'Entregado',
            self::RETURNED => 'Devuelto',
            self::CANCELLED => 'Cancelado',
            self::DELAYED => 'Retrasado',
        };
    }

    public static function values(): array
    {
        return array_column(self::cases(), 'value');
    }
}
