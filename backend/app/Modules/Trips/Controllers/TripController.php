<?php

namespace App\Modules\Trips\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Packages\Models\Package;
use App\Modules\Packages\Resources\PackageResource;
use App\Modules\Routes\Models\Route;
use App\Modules\Trips\Models\Trip;
use App\Modules\Trips\Requests\CreateTripRequest;
use App\Modules\Trips\Requests\UpdateTripRequest;
use App\Modules\Trips\Resources\TripResource;
use App\Shared\Enums\PackageStatus;
use App\Shared\Enums\TripStatus;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class TripController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = Trip::forTransporter($request->user()->id)
            ->with(['stops', 'route'])
            ->withCount('packages');

        if ($request->filled('status')) {
            $query->byStatus($request->status);
        }

        if ($request->boolean('upcoming')) {
            $query->upcoming();
        }

        if ($request->boolean('active')) {
            $query->active();
        }

        if ($request->filled('from') || $request->filled('to')) {
            $query->byDateRange($request->from, $request->to);
        }

        $perPage = min($request->integer('per_page', 15), 100);

        $trips = $query->orderBy('departure_date', 'desc')
            ->paginate($perPage);

        return TripResource::collection($trips);
    }

    public function store(CreateTripRequest $request): JsonResponse
    {
        $this->authorize('create', Trip::class);

        $validated = $request->validated();
        $validated['transporter_id'] = $request->user()->id;
        $validated['status'] = TripStatus::PLANNED->value;

        $stops = $validated['stops'] ?? [];
        unset($validated['stops']);

        $trip = Trip::create($validated);

        foreach ($stops as $index => $stopData) {
            $trip->stops()->create([
                'city' => $stopData['city'],
                'country' => $stopData['country'],
                'order' => $stopData['order'] ?? $index,
            ]);
        }

        return response()->json(new TripResource($trip->load('stops')), 201);
    }

    public function storeFromRoute(Request $request, Route $route): JsonResponse
    {
        $this->authorize('view', $route);
        $this->authorize('create', Trip::class);

        $validated = $request->validate([
            'departure_date' => 'required|date',
            'departure_time' => 'nullable|date_format:H:i',
            'estimated_arrival_date' => 'nullable|date|after_or_equal:departure_date',
            'notes' => 'nullable|string|max:1000',
        ]);

        $trip = Trip::create([
            'route_id' => $route->id,
            'transporter_id' => $request->user()->id,
            'origin_city' => $route->origin_city,
            'origin_country' => $route->origin_country,
            'destination_city' => $route->destination_city,
            'destination_country' => $route->destination_country,
            'departure_date' => $validated['departure_date'],
            'departure_time' => $validated['departure_time'] ?? null,
            'estimated_arrival_date' => $validated['estimated_arrival_date'] ?? null,
            'status' => TripStatus::PLANNED->value,
            'notes' => $validated['notes'] ?? null,
            'price_per_kg' => $route->price_per_kg,
            'minimum_price' => $route->minimum_price,
            'price_multiplier' => $route->price_multiplier,
        ]);

        // Copy stops from route template
        foreach ($route->stops as $stop) {
            $trip->stops()->create([
                'city' => $stop->city,
                'country' => $stop->country,
                'order' => $stop->order,
            ]);
        }

        return response()->json(new TripResource($trip->load('stops')), 201);
    }

    public function show(Request $request, Trip $trip): JsonResponse
    {
        $this->authorize('view', $trip);

        return response()->json(new TripResource($trip->load(['stops', 'route'])->loadCount('packages')));
    }

    public function update(UpdateTripRequest $request, Trip $trip): JsonResponse
    {
        $this->authorize('update', $trip);

        $trip->update($request->validated());

        return response()->json(new TripResource($trip->load('stops')));
    }

    public function destroy(Request $request, Trip $trip): JsonResponse
    {
        $this->authorize('delete', $trip);

        $trip->delete();

        return response()->json(['message' => 'Viaje eliminado correctamente']);
    }

    public function updateStatus(Request $request, Trip $trip): JsonResponse
    {
        $this->authorize('update', $trip);

        $validated = $request->validate([
            'status' => 'required|string|in:'.implode(',', TripStatus::values()),
        ]);

        $updateData = ['status' => $validated['status']];

        if ($validated['status'] === TripStatus::COMPLETED->value && ! $trip->actual_arrival_date) {
            $updateData['actual_arrival_date'] = now();
        }

        $trip->update($updateData);

        return response()->json(new TripResource($trip->load('stops')));
    }

    public function packages(Request $request, Trip $trip): AnonymousResourceCollection
    {
        $this->authorize('view', $trip);

        $packages = $trip->packages()
            ->with(['trip'])
            ->orderBy('created_at', 'desc')
            ->get();

        return PackageResource::collection($packages);
    }

    public function assignPackages(Request $request, Trip $trip): JsonResponse
    {
        $this->authorize('update', $trip);

        $validated = $request->validate([
            'package_ids' => 'required|array',
            'package_ids.*' => 'exists:packages,id',
        ]);

        $nonAssignableStatuses = [
            PackageStatus::DELIVERED->value,
            PackageStatus::CANCELLED->value,
        ];

        $updated = Package::whereIn('id', $validated['package_ids'])
            ->where('transporter_id', $request->user()->id)
            ->whereNotIn('status', $nonAssignableStatuses)
            ->update(['trip_id' => $trip->id]);

        return response()->json([
            'message' => 'Paquetes asignados correctamente',
            'assigned_count' => $updated,
            'trip' => new TripResource($trip->load('stops')->loadCount('packages')),
        ]);
    }
}
