<?php

namespace App\Modules\Packages\Policies;

use App\Models\User;
use App\Modules\Packages\Models\Package;

class PackagePolicy
{
    public function viewAny(User $user): bool
    {
        return true;
    }

    public function view(User $user, Package $package): bool
    {
        return $user->id === $package->transporter_id;
    }

    public function create(User $user): bool
    {
        return true;
    }

    public function update(User $user, Package $package): bool
    {
        return $user->id === $package->transporter_id;
    }

    public function delete(User $user, Package $package): bool
    {
        return $user->id === $package->transporter_id;
    }
}
