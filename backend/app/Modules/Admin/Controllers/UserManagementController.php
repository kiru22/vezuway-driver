<?php

namespace App\Modules\Admin\Controllers;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Modules\Admin\Resources\PendingDriverResource;
use App\Modules\Admin\Services\UserManagementService;
use App\Modules\Auth\Resources\UserResource;
use App\Shared\Enums\DriverStatus;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UserManagementController extends Controller
{
    public function __construct(private readonly UserManagementService $service) {}

    public function allUsers(Request $request): JsonResponse
    {
        $query = User::query()
            ->whereHas('roles', fn ($q) => $q->whereIn('name', ['client', 'driver']))
            ->orderBy('created_at', 'desc');

        // Filter by role
        if ($request->filled('role')) {
            $role = $request->input('role');
            if (in_array($role, ['client', 'driver'])) {
                $query->whereHas('roles', fn ($q) => $q->where('name', $role));
            }
        }

        // Search by name or email
        if ($request->filled('search')) {
            $search = $request->input('search');
            $query->where(function ($q) use ($search) {
                $q->where('name', 'ilike', "%{$search}%")
                    ->orWhere('email', 'ilike', "%{$search}%");
            });
        }

        $users = $query->paginate(20);

        return response()->json(UserResource::collection($users));
    }

    public function pendingDrivers(): JsonResponse
    {
        $drivers = User::role('driver')
            ->where('driver_status', DriverStatus::PENDING->value)
            ->orderBy('created_at', 'desc')
            ->paginate(15);

        return response()->json(PendingDriverResource::collection($drivers));
    }

    public function approveDriver(User $user): JsonResponse
    {
        // Validar que es un driver pending
        if (! $user->hasRole('driver') || $user->driver_status !== DriverStatus::PENDING) {
            return response()->json([
                'message' => 'El usuario no es un conductor pendiente',
            ], 422);
        }

        $this->service->approveDriver($user);

        return response()->json(new UserResource($user->fresh()));
    }

    public function rejectDriver(Request $request, User $user): JsonResponse
    {
        $validated = $request->validate([
            'reason' => 'nullable|string|max:500',
        ]);

        // Validar que es un driver pending
        if (! $user->hasRole('driver') || $user->driver_status !== DriverStatus::PENDING) {
            return response()->json([
                'message' => 'El usuario no es un conductor pendiente',
            ], 422);
        }

        $this->service->rejectDriver($user, $validated['reason'] ?? null);

        return response()->json(new UserResource($user->fresh()));
    }
}
