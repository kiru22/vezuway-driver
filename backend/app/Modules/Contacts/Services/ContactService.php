<?php

namespace App\Modules\Contacts\Services;

use App\Modules\Contacts\Models\Contact;
use Illuminate\Database\Eloquent\Collection;

class ContactService
{
    /**
     * Buscar o crear contacto desde datos de paquete
     * Busca por email o phone, si no existe crea nuevo
     *
     * @param  array  $data  Datos del contacto (name, email, phone, address, city, country, lat, lng)
     * @param  string  $createdBy  User ID del transportista
     */
    public function findOrCreateFromPackageData(array $data, string $createdBy): Contact
    {
        // Buscar contacto existente por email o phone
        $query = Contact::where('created_by_user_id', $createdBy);

        if (! empty($data['email'])) {
            $query->where('email', $data['email']);
        } elseif (! empty($data['phone'])) {
            $query->where('phone', $data['phone']);
        } else {
            // Si no hay email ni phone, siempre crear nuevo
            return $this->createContact($data, $createdBy);
        }

        $contact = $query->first();

        if ($contact) {
            // Actualizar datos si han cambiado
            $this->updateContactIfChanged($contact, $data);

            return $contact;
        }

        return $this->createContact($data, $createdBy);
    }

    /**
     * Crear nuevo contacto
     */
    private function createContact(array $data, string $createdBy): Contact
    {
        return Contact::create([
            'created_by_user_id' => $createdBy,
            'name' => $data['name'] ?? 'Sin nombre',
            'email' => $data['email'] ?? null,
            'phone' => $data['phone'] ?? null,
            'address' => $data['address'] ?? null,
            'city' => $data['city'] ?? null,
            'country' => $data['country'] ?? null,
            'latitude' => $data['latitude'] ?? null,
            'longitude' => $data['longitude'] ?? null,
        ]);
    }

    /**
     * Actualizar contacto si los datos han cambiado
     */
    private function updateContactIfChanged(Contact $contact, array $data): void
    {
        $fields = ['name', 'address', 'city', 'country', 'latitude', 'longitude'];
        $updates = [];

        foreach ($fields as $field) {
            if (isset($data[$field]) && $contact->{$field} != $data[$field]) {
                $updates[$field] = $data[$field];
            }
        }

        if (! empty($updates)) {
            $contact->update($updates);
        }
    }

    /**
     * Buscar contactos por query
     * Búsqueda rápida por name/email/phone
     *
     * @param  string  $query  Término de búsqueda
     * @param  string  $userId  ID del transportista
     * @param  int  $limit  Límite de resultados
     */
    public function searchContacts(string $query, string $userId, int $limit = 10): Collection
    {
        return Contact::forTransporter($userId)
            ->search($query)
            ->orderBy('last_package_at', 'desc')
            ->orderBy('name')
            ->limit($limit)
            ->get();
    }

    /**
     * Recalcular contadores de paquetes de un contacto
     * Se ejecuta de forma asíncrona para no bloquear
     */
    public function updatePackageCounters(Contact $contact): void
    {
        $contact->updatePackageCounters();
    }

    /**
     * Vincular contacto a usuario (cuando se registra)
     *
     * @param  string  $email  Email del contacto
     * @param  string  $userId  ID del usuario
     */
    public function linkContactToUser(string $email, string $userId): ?Contact
    {
        $contact = Contact::where('email', $email)
            ->whereNull('user_id')
            ->first();

        if ($contact) {
            $contact->linkToUser($userId);

            return $contact;
        }

        return null;
    }
}
