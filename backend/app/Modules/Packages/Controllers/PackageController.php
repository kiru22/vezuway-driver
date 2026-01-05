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
        $query = Package::forTransporter($request->user()->id)
            ->with(['route', 'transporter']);

        if ($request->filled('search')) {
            $query->search($request->search);
        }

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->filled('route_id')) {
            $query->where('route_id', $request->route_id);
        }

        $packages = $query->orderBy('created_at', 'desc')
            ->paginate($request->per_page ?? 15);

        return PackageResource::collection($packages);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'sender_name' => 'required|string|max:255',
            'sender_phone' => 'nullable|string|max:50',
            'sender_address' => 'required|string',
            'sender_city' => 'nullable|string|max:100',
            'sender_country' => 'nullable|string|max:2',
            'receiver_name' => 'required|string|max:255',
            'receiver_phone' => 'nullable|string|max:50',
            'receiver_address' => 'required|string',
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
        ]);

        $validated['transporter_id'] = $request->user()->id;
        $validated['sender_country'] = $validated['sender_country'] ?? 'UA';
        $validated['receiver_country'] = $validated['receiver_country'] ?? 'ES';

        $package = Package::create($validated);

        $package->statusHistory()->create([
            'status' => PackageStatus::PENDING->value,
            'created_by' => $request->user()->id,
            'notes' => 'Paquete creado',
        ]);

        return response()->json(new PackageResource($package->load(['route', 'transporter'])), 201);
    }

    public function show(Request $request, Package $package): JsonResponse
    {
        $this->authorize('view', $package);

        return response()->json(new PackageResource($package->load(['route', 'transporter', 'statusHistory.createdBy'])));
    }

    public function update(Request $request, Package $package): JsonResponse
    {
        $this->authorize('update', $package);

        $validated = $request->validate([
            'sender_name' => 'sometimes|string|max:255',
            'sender_phone' => 'nullable|string|max:50',
            'sender_address' => 'sometimes|string',
            'sender_city' => 'nullable|string|max:100',
            'sender_country' => 'nullable|string|max:2',
            'receiver_name' => 'sometimes|string|max:255',
            'receiver_phone' => 'nullable|string|max:50',
            'receiver_address' => 'sometimes|string',
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
        ]);

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

        $package->statusHistory()->create([
            'status' => $validated['status'],
            'notes' => $validated['notes'] ?? null,
            'latitude' => $validated['latitude'] ?? null,
            'longitude' => $validated['longitude'] ?? null,
            'created_by' => $request->user()->id,
        ]);

        $package->update(['status' => $validated['status']]);

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

        foreach ($packages as $package) {
            $package->statusHistory()->create([
                'status' => $validated['status'],
                'notes' => $validated['notes'] ?? 'Cambio masivo de estado',
                'created_by' => $request->user()->id,
            ]);

            $package->update(['status' => $validated['status']]);
        }

        return response()->json([
            'message' => 'Estados actualizados correctamente',
            'updated_count' => $packages->count(),
        ]);
    }
}
