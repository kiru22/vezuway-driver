<?php

namespace App\Modules\Contacts\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Contacts\Models\Contact;
use App\Modules\Contacts\Requests\StoreContactRequest;
use App\Modules\Contacts\Requests\UpdateContactRequest;
use App\Modules\Contacts\Resources\ContactResource;
use App\Modules\Contacts\Services\ContactService;
use App\Modules\Packages\Models\Package;
use App\Modules\Packages\Resources\PackageResource;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;

class ContactController extends Controller
{
    public function __construct(private readonly ContactService $contactService) {}

    /**
     * Lista paginada de contactos del transportista
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        $this->authorize('viewAny', Contact::class);

        $query = Contact::forTransporter($request->user()->id)
            ->with(['user']);

        // Búsqueda
        if ($search = $request->input('search')) {
            $query->search($search);
        }

        // Filtro de verificados
        if ($request->boolean('verified')) {
            $query->verified();
        }

        // Ordenar por última actividad
        $query->orderBy('last_package_at', 'desc')
            ->orderBy('name');

        $contacts = $query->paginate($request->input('per_page', 20));

        return ContactResource::collection($contacts);
    }

    /**
     * Búsqueda rápida para typeahead (máximo 10 resultados)
     */
    public function search(Request $request): AnonymousResourceCollection
    {
        $this->authorize('viewAny', Contact::class);

        $query = $request->input('q', '');

        if (strlen($query) < 2) {
            return ContactResource::collection([]);
        }

        $contacts = $this->contactService->searchContacts(
            $query,
            $request->user()->id,
            limit: 10
        );

        return ContactResource::collection($contacts);
    }

    /**
     * Crear nuevo contacto
     */
    public function store(StoreContactRequest $request): ContactResource
    {
        $this->authorize('create', Contact::class);

        $contact = Contact::create([
            ...$request->validated(),
            'created_by_user_id' => $request->user()->id,
        ]);

        return ContactResource::make($contact);
    }

    /**
     * Mostrar detalle de contacto
     */
    public function show(Request $request, string $id): ContactResource
    {
        $contact = Contact::with(['user', 'creator'])->findOrFail($id);

        $this->authorize('view', $contact);

        return ContactResource::make($contact);
    }

    /**
     * Actualizar contacto
     */
    public function update(UpdateContactRequest $request, string $id): ContactResource
    {
        $contact = Contact::findOrFail($id);

        $this->authorize('update', $contact);

        $contact->update($request->validated());

        return ContactResource::make($contact->fresh());
    }

    /**
     * Eliminar contacto (soft delete)
     */
    public function destroy(Request $request, string $id): Response
    {
        $contact = Contact::findOrFail($id);

        $this->authorize('delete', $contact);

        $contact->delete();

        return response()->noContent();
    }

    /**
     * Histórico de paquetes de un contacto
     */
    public function packages(Request $request, string $id): AnonymousResourceCollection
    {
        $contact = Contact::findOrFail($id);

        $this->authorize('view', $contact);

        $packages = Package::where(function ($query) use ($id) {
            $query->where('sender_contact_id', $id)
                ->orWhere('receiver_contact_id', $id);
        })
            ->with(['trip', 'transporter', 'senderContact', 'receiverContact'])
            ->latest('created_at')
            ->paginate($request->input('per_page', 20));

        return PackageResource::collection($packages);
    }
}
