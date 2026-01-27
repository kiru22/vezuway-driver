<?php

namespace App\Http\Middleware;

use App\Shared\Enums\DriverStatus;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureDriverApproved
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        // Si no tiene rol asignado (aún no seleccionó) → permitir para ruta de selección
        if ($user->roles()->count() === 0) {
            return $next($request);
        }

        // Si es DRIVER, verificar status
        if ($user->hasRole('driver')) {
            if ($user->driver_status !== DriverStatus::APPROVED) {
                return response()->json([
                    'message' => 'Tu cuenta está pendiente de aprobación',
                    'driver_status' => $user->driver_status?->value ?? 'pending',
                ], 403);
            }
        }

        // CLIENT y SUPER_ADMIN → permitir
        return $next($request);
    }
}
