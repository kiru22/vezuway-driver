<?php

namespace App\Modules\Packages\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Packages\Models\Package;
use App\Modules\Packages\Resources\PackageResource;
use App\Shared\Enums\PackageStatus;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class PackageController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $packages = Package::forTransporter($request->user()->id)
            ->with(['route', 'transporter'])
            ->when($request->filled('search'), fn ($q) => $q->search($request->search))
            ->when($request->filled('status'), fn ($q) => $q->where('status', $request->status))
            ->when($request->filled('route_id'), fn ($q) => $q->where('route_id', $request->route_id))
            ->orderBy('created_at', 'desc')
            ->paginate(min($request->integer('per_page', 15), 100));

        return PackageResource::collection($packages);
    }

    public function store(Request $request): JsonResponse
    {
        $this->authorize('create', Package::class);

        $rules = $this->getBaseValidationRules();
        $rules['receiver_name'] = 'required|string|max:255';
        $rules['receiver_address'] = 'required|string';
        $rules['images'] = 'nullable|array|max:10';
        $rules['images.*'] = 'file|image|max:10240';

        $validated = $request->validate($rules);

        $validated['transporter_id'] = $request->user()->id;
        $validated['sender_country'] = $validated['sender_country'] ?? 'UA';
        $validated['receiver_country'] = $validated['receiver_country'] ?? 'ES';
        $validated['status'] = PackageStatus::PENDING;

        $images = $validated['images'] ?? [];
        unset($validated['images']);

        $package = Package::create($validated);

        foreach ($images as $image) {
            $package->addMedia($image)->toMediaCollection('images');
        }

        $package->recordStatusChange(PackageStatus::PENDING, $request->user()->id, 'Paquete creado');

        return response()->json(new PackageResource($package->load(['route', 'transporter', 'media'])), 201);
    }

    public function show(Request $request, Package $package): JsonResponse
    {
        $this->authorize('view', $package);

        return response()->json(new PackageResource($package->load(['route', 'transporter', 'statusHistory.createdBy', 'media'])));
    }

    public function update(Request $request, Package $package): JsonResponse
    {
        $this->authorize('update', $package);

        $rules = collect($this->getBaseValidationRules())
            ->map(fn ($rule) => "sometimes|{$rule}")
            ->toArray();

        $validated = $request->validate($rules);
        $package->update($validated);

        return response()->json(new PackageResource($package->load(['route', 'transporter'])));
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

        return response()->json(new PackageResource($package->load(['route', 'transporter', 'statusHistory'])));
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
            'notes' => 'nullable|string',
        ];
    }
}
