<?php

namespace App\Modules\Packages\Policies;

use App\Models\User;
use App\Modules\Packages\Models\Package;

class PackagePolicy
{
    public function viewAny(User $user): bool
    {
        return $user->isSuperAdmin() || $user->isApprovedDriver() || $user->isClient();
    }

    public function view(User $user, Package $package): bool
    {
        if ($user->isSuperAdmin()) {
            return true;
        }

        if ($user->isDriver()) {
            return $user->id === $package->transporter_id;
        }

        if ($user->isClient()) {
            $contact = $user->contact;

            return $contact && ($package->sender_contact_id === $contact->id
                || $package->receiver_contact_id === $contact->id);
        }

        return false;
    }

    public function create(User $user): bool
    {
        return true;
    }

    public function update(User $user, Package $package): bool
    {
        return $user->isSuperAdmin() || $user->id === $package->transporter_id;
    }

    public function delete(User $user, Package $package): bool
    {
        return $user->isSuperAdmin() || $user->id === $package->transporter_id;
    }
}
