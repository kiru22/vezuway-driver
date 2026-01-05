<?php

namespace App\Policies;

use App\Models\User;
use App\Modules\Routes\Models\Route;

class RoutePolicy
{
    public function create(User $user): bool
    {
        return true;
    }

    public function view(User $user, Route $route): bool
    {
        return $user->id === $route->transporter_id;
    }

    public function update(User $user, Route $route): bool
    {
        return $user->id === $route->transporter_id;
    }

    public function delete(User $user, Route $route): bool
    {
        return $user->id === $route->transporter_id;
    }
}
