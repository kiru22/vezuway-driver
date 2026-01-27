<?php

namespace App\Modules\Routes\Policies;

use App\Models\User;
use App\Modules\Routes\Models\Route;

class RoutePolicy
{
    public function viewAny(User $user): bool
    {
        return $user->isApprovedDriver() || $user->isSuperAdmin();
    }

    public function view(User $user, Route $route): bool
    {
        return $this->isOwnerOrAdmin($user, $route);
    }

    public function create(User $user): bool
    {
        return $user->isApprovedDriver() || $user->isSuperAdmin();
    }

    public function update(User $user, Route $route): bool
    {
        return $this->isOwnerOrAdmin($user, $route);
    }

    public function delete(User $user, Route $route): bool
    {
        return $this->isOwnerOrAdmin($user, $route);
    }

    private function isOwnerOrAdmin(User $user, Route $route): bool
    {
        return $user->isSuperAdmin() || $user->id === $route->transporter_id;
    }
}
