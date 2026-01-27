<?php

namespace App\Modules\Trips\Policies;

use App\Models\User;
use App\Modules\Trips\Models\Trip;

class TripPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->isApprovedDriver() || $user->isSuperAdmin();
    }

    public function view(User $user, Trip $trip): bool
    {
        return $this->isOwnerOrAdmin($user, $trip);
    }

    public function create(User $user): bool
    {
        return $user->isApprovedDriver() || $user->isSuperAdmin();
    }

    public function update(User $user, Trip $trip): bool
    {
        return $this->isOwnerOrAdmin($user, $trip);
    }

    public function delete(User $user, Trip $trip): bool
    {
        return $this->isOwnerOrAdmin($user, $trip);
    }

    private function isOwnerOrAdmin(User $user, Trip $trip): bool
    {
        return $user->isSuperAdmin() || $user->id === $trip->transporter_id;
    }
}
