<?php

namespace App\Modules\Contacts\Policies;

use App\Models\User;
use App\Modules\Contacts\Models\Contact;

class ContactPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->isApprovedDriver() || $user->isSuperAdmin();
    }

    public function view(User $user, Contact $contact): bool
    {
        return $this->isOwnerOrAdmin($user, $contact)
            || $user->id === $contact->user_id;
    }

    public function create(User $user): bool
    {
        return $user->isApprovedDriver() || $user->isSuperAdmin();
    }

    public function update(User $user, Contact $contact): bool
    {
        return $this->isOwnerOrAdmin($user, $contact);
    }

    public function delete(User $user, Contact $contact): bool
    {
        return $this->isOwnerOrAdmin($user, $contact);
    }

    public function restore(User $user, Contact $contact): bool
    {
        return $this->isOwnerOrAdmin($user, $contact);
    }

    public function forceDelete(User $user, Contact $contact): bool
    {
        return $this->isOwnerOrAdmin($user, $contact);
    }

    private function isOwnerOrAdmin(User $user, Contact $contact): bool
    {
        return $user->isSuperAdmin() || $user->id === $contact->created_by_user_id;
    }
}
