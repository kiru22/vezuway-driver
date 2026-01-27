<?php

namespace App\Modules\Packages\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Contacts\Services\ContactService;
use App\Modules\Packages\Models\Package;
use App\Modules\Packages\Resources\PackageResource;
use App\Shared\Enums\PackageStatus;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class PackageController extends Controller
{
    public function __construct(private readonly ContactService $contactService) {}

    public function index(Request $request): AnonymousResourceCollection
    {
        $user = $request->user();
        $query = Package::query();

        if ($user->isClient()) {
            $contact = $user->contact;
            if (! $contact) {
                return PackageResource::collection(collect([]));
            }

            $query->forContact($contact->id);
        } elseif ($user->isDriver()) {
            $query->forTransporter($user->id);
        }

        $packages = $query
            ->with(['route', 'trip', 'transporter', 'senderContact', 'receiverContact'])
            ->when($request->filled('search'), fn ($q) => $q->search($request->search))
            ->when($request->filled('status'), fn ($q) => $q->where('status', $request->status))
            ->when($request->filled('route_id'), fn ($q) => $q->where('route_id', $request->route_id))
            ->orderBy('created_at', 'desc')
            ->paginate(min($request->integer('per_page', 15), 100));

        return PackageResource::collection($packages);
    }

    public function counts(Request $request): JsonResponse
    {
        $baseQuery = Package::forTransporter($request->user()->id);

        $counts = [
            'total' => (clone $baseQuery)->count(),
            'pending' => (clone $baseQuery)->where('status', PackageStatus::PENDING)->count(),
            'in_transit' => (clone $baseQuery)->where('status', PackageStatus::IN_TRANSIT)->count(),
            'delivered' => (clone $baseQuery)->where('status', PackageStatus::DELIVERED)->count(),
            'delayed' => (clone $baseQuery)->where('status', PackageStatus::DELAYED)->count(),
        ];

        return response()->json(['data' => $counts]);
    }

    public function clientStats(Request $request): JsonResponse
    {
        $user = $request->user();

        if (! $user->isClient()) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $contact = $user->contact;
        if (! $contact) {
            return response()->json(['data' => [
                'total' => 0,
                'pending' => 0,
                'in_transit' => 0,
                'delivered' => 0,
                'delayed' => 0,
                'total_weight' => 0,
                'total_declared_value' => 0,
            ]]);
        }

        $baseQuery = Package::forContact($contact->id);

        $stats = [
            'total' => (clone $baseQuery)->count(),
            'pending' => (clone $baseQuery)->where('status', PackageStatus::PENDING)->count(),
            'in_transit' => (clone $baseQuery)->where('status', PackageStatus::IN_TRANSIT)->count(),
            'delivered' => (clone $baseQuery)->where('status', PackageStatus::DELIVERED)->count(),
            'delayed' => (clone $baseQuery)->where('status', PackageStatus::DELAYED)->count(),
            'total_weight' => (clone $baseQuery)->sum('weight_kg') ?? 0,
            'total_declared_value' => (clone $baseQuery)->sum('declared_value') ?? 0,
        ];

        return response()->json(['data' => $stats]);
    }

    public function store(Request $request): JsonResponse
    {
        $this->authorize('create', Package::class);

        $rules = $this->getBaseValidationRules();
        $rules['receiver_name'] = 'required|string|max:255';
        // receiver_address is optional, receiver_city can be used instead
        $rules['images'] = 'nullable|array|max:10';
        $rules['images.*'] = 'file|image|max:10240';
        $rules['sender_contact_id'] = 'nullable|exists:contacts,id';
        $rules['receiver_contact_id'] = 'nullable|exists:contacts,id';

        $validated = $request->validate($rules);

        $validated['transporter_id'] = $request->user()->id;
        $validated['sender_country'] = $validated['sender_country'] ?? 'UA';
        $validated['receiver_country'] = $validated['receiver_country'] ?? 'ES';
        $validated['status'] = PackageStatus::PENDING;

        // Buscar o crear contactos si no vienen IDs
        if (empty($validated['sender_contact_id']) && ! empty($validated['sender_name'])) {
            $senderContact = $this->contactService->findOrCreateFromPackageData([
                'name' => $validated['sender_name'],
                'email' => $validated['sender_email'] ?? null,
                'phone' => $validated['sender_phone'] ?? null,
                'address' => $validated['sender_address'] ?? null,
                'city' => $validated['sender_city'] ?? null,
                'country' => $validated['sender_country'] ?? 'UA',
                'latitude' => $validated['sender_latitude'] ?? null,
                'longitude' => $validated['sender_longitude'] ?? null,
            ], $request->user()->id);

            $validated['sender_contact_id'] = $senderContact->id;
        }

        if (empty($validated['receiver_contact_id']) && ! empty($validated['receiver_name'])) {
            $receiverContact = $this->contactService->findOrCreateFromPackageData([
                'name' => $validated['receiver_name'],
                'email' => $validated['receiver_email'] ?? null,
                'phone' => $validated['receiver_phone'] ?? null,
                'address' => $validated['receiver_address'] ?? null,
                'city' => $validated['receiver_city'] ?? null,
                'country' => $validated['receiver_country'] ?? 'ES',
                'latitude' => $validated['receiver_latitude'] ?? null,
                'longitude' => $validated['receiver_longitude'] ?? null,
            ], $request->user()->id);

            $validated['receiver_contact_id'] = $receiverContact->id;
        }

        $images = $validated['images'] ?? [];
        unset($validated['images']);

        $package = Package::create($validated);

        foreach ($images as $image) {
            $package->addMedia($image)->toMediaCollection('images');
        }

        $package->recordStatusChange(PackageStatus::PENDING, $request->user()->id, 'Paquete creado');

        dispatch(function () use ($package) {
            $package->senderContact?->updatePackageCounters();
            $package->receiverContact?->updatePackageCounters();
        })->afterResponse();

        return response()->json(new PackageResource($package->load(['route', 'trip', 'transporter', 'senderContact', 'receiverContact', 'media'])), 201);
    }

    public function show(Request $request, Package $package): JsonResponse
    {
        $this->authorize('view', $package);

        return response()->json(new PackageResource($package->load(['route', 'trip', 'transporter', 'senderContact', 'receiverContact', 'statusHistory.createdBy', 'media'])));
    }

    public function update(Request $request, Package $package): JsonResponse
    {
        $this->authorize('update', $package);

        $rules = collect($this->getBaseValidationRules())
            ->map(fn ($rule) => "sometimes|{$rule}")
            ->toArray();

        $validated = $request->validate($rules);
        $package->update($validated);

        return response()->json(new PackageResource($package->load(['route', 'trip', 'transporter'])));
    }

    public function destroy(Request $request, Package $package): JsonResponse
    {
        $this->authorize('delete', $package);

        $package->delete();

        return response()->json(['message' => 'Paquete eliminado correctamente']);
    }

    public function updateStatus(Request $request, Package $package): JsonResponse
    {
        $this->authorize('update', $package);

        $validated = $request->validate([
            'status' => 'required|string|in:'.implode(',', PackageStatus::values()),
            'notes' => 'nullable|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
        ]);

        $package->recordStatusChange(
            PackageStatus::from($validated['status']),
            $request->user()->id,
            $validated['notes'] ?? null,
            $validated['latitude'] ?? null,
            $validated['longitude'] ?? null
        );

        return response()->json(new PackageResource($package->load(['route', 'trip', 'transporter', 'statusHistory'])));
    }

    public function history(Request $request, Package $package): JsonResponse
    {
        $this->authorize('view', $package);

        return response()->json($package->statusHistory()->with('createdBy')->get());
    }

    public function bulkUpdateStatus(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'package_ids' => 'required|array',
            'package_ids.*' => 'exists:packages,id',
            'status' => 'required|string|in:'.implode(',', PackageStatus::values()),
            'notes' => 'nullable|string',
        ]);

        $packages = Package::whereIn('id', $validated['package_ids'])
            ->where('transporter_id', $request->user()->id)
            ->get();

        $status = PackageStatus::from($validated['status']);
        $notes = $validated['notes'] ?? 'Cambio masivo de estado';
        $userId = $request->user()->id;

        foreach ($packages as $package) {
            $package->recordStatusChange($status, $userId, $notes);
        }

        return response()->json([
            'message' => 'Estados actualizados correctamente',
            'updated_count' => $packages->count(),
        ]);
    }

    public function addImages(Request $request, Package $package): JsonResponse
    {
        $this->authorize('update', $package);

        $validated = $request->validate([
            'images' => 'required|array|min:1|max:10',
            'images.*' => 'file|image|max:10240', // Max 10MB per image
        ]);

        $addedMedia = [];
        foreach ($validated['images'] as $image) {
            $media = $package->addMedia($image)->toMediaCollection('images');
            $addedMedia[] = [
                'id' => $media->id,
                'url' => $media->getUrl(),
                'thumb_url' => $media->getUrl('thumb'),
            ];
        }

        return response()->json([
            'message' => 'Imágenes añadidas correctamente',
            'images' => $addedMedia,
        ]);
    }

    public function deleteImage(Request $request, Package $package, int $mediaId): JsonResponse
    {
        $this->authorize('update', $package);

        $media = $package->media()->where('id', $mediaId)->first();

        if (! $media) {
            return response()->json(['message' => 'Imagen no encontrada'], 404);
        }

        $media->delete();

        return response()->json(['message' => 'Imagen eliminada correctamente']);
    }

    public function myOrders(Request $request): AnonymousResourceCollection
    {
        $contact = $request->user()->contact;

        if (! $contact) {
            return PackageResource::collection([]);
        }

        $packages = Package::forContact($contact->id)
            ->with(['trip', 'transporter', 'senderContact', 'receiverContact'])
            ->latest('created_at')
            ->paginate($request->input('per_page', 20));

        return PackageResource::collection($packages);
    }

    private function getBaseValidationRules(): array
    {
        return [
            'sender_name' => 'nullable|string|max:255',
            'sender_phone' => 'nullable|string|max:50',
            'sender_address' => 'nullable|string',
            'sender_city' => 'nullable|string|max:100',
            'sender_country' => 'nullable|string|max:2',
            'receiver_name' => 'nullable|string|max:255',
            'receiver_phone' => 'nullable|string|max:50',
            'receiver_address' => 'nullable|string',
            'receiver_city' => 'nullable|string|max:100',
            'receiver_country' => 'nullable|string|max:2',
            'weight_kg' => 'nullable|numeric|min:0',
            'length_cm' => 'nullable|integer|min:0',
            'width_cm' => 'nullable|integer|min:0',
            'height_cm' => 'nullable|integer|min:0',
            'description' => 'nullable|string',
            'declared_value' => 'nullable|numeric|min:0',
            'route_id' => 'nullable|exists:routes,id',
            'trip_id' => 'nullable|exists:trips,id',
            'notes' => 'nullable|string',
        ];
    }
}
