<?php

namespace App\Modules\Routes\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Packages\Models\Package;
use App\Modules\Packages\Resources\PackageResource;
use App\Modules\Routes\Models\Route;
use App\Modules\Routes\Resources\RouteResource;
use App\Shared\Enums\PackageStatus;
use App\Shared\Enums\RouteStatus;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class RouteController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = Route::forTransporter($request->user()->id)
            ->with(['schedules', 'stops'])
            ->withCount('packages');

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->boolean('upcoming')) {
            $query->upcoming();
        }

        if ($request->boolean('active')) {
            $query->active();
        }

        $perPage = min($request->integer('per_page', 15), 100);

        $routes = $query->orderBy('departure_date', 'desc')
            ->paginate($perPage);

        return RouteResource::collection($routes);
    }

    public function store(Request $request): JsonResponse
    {
        $this->authorize('create', Route::class);

        $validated = $request->validate([
            'origin_city' => 'required|string|max:100',
            'origin_country' => 'required|string|max:2',
            'destination_city' => 'required|string|max:100',
            'destination_country' => 'required|string|max:2',
            // Support both single date and array of dates
            'departure_date' => 'required_without:departure_dates|date',
            'departure_dates' => 'required_without:departure_date|array|min:1',
            'departure_dates.*' => 'date',
            'trip_duration_hours' => 'nullable|integer|min:1',
            'estimated_arrival_date' => 'nullable|date',
            'vehicle_info' => 'nullable|array',
            'notes' => 'nullable|string',
            'price_per_kg' => 'nullable|numeric|min:0|max:9999.99',
            'minimum_price' => 'nullable|numeric|min:0|max:9999.99',
            'price_multiplier' => 'nullable|numeric|min:0.1|max:10',
            'stops' => 'nullable|array',
            'stops.*.city' => 'required_with:stops|string|max:100',
            'stops.*.country' => 'required_with:stops|string|max:2',
            'stops.*.order' => 'nullable|integer|min:0',
        ]);

        $validated['transporter_id'] = $request->user()->id;
        $validated['status'] = RouteStatus::PLANNED->value;

        // Get departure dates (support both formats)
        $departureDates = $validated['departure_dates'] ?? [$validated['departure_date']];
        $tripDurationHours = $validated['trip_duration_hours'] ?? null;

        // Set the first departure date as the main route date (for backward compatibility)
        $firstDate = collect($departureDates)->sort()->first();
        $validated['departure_date'] = $firstDate;

        if ($tripDurationHours && ! isset($validated['estimated_arrival_date'])) {
            $validated['estimated_arrival_date'] = Carbon::parse($firstDate)->addHours($tripDurationHours);
        }

        // Extract stops before creating route
        $stops = $validated['stops'] ?? [];

        // Remove array fields before creating route
        unset($validated['departure_dates'], $validated['trip_duration_hours'], $validated['stops']);

        $route = Route::create($validated);

        // Create stops for the route
        foreach ($stops as $index => $stopData) {
            $route->stops()->create([
                'city' => $stopData['city'],
                'country' => $stopData['country'],
                'order' => $stopData['order'] ?? $index,
            ]);
        }

        // Create schedule entries for each date
        foreach ($departureDates as $date) {
            $estimatedArrival = $tripDurationHours
                ? Carbon::parse($date)->addHours($tripDurationHours)
                : $validated['estimated_arrival_date'] ?? null;

            $route->schedules()->create([
                'departure_date' => $date,
                'estimated_arrival_date' => $estimatedArrival,
                'status' => RouteStatus::PLANNED->value,
            ]);
        }

        return response()->json(new RouteResource($route->load(['schedules', 'stops'])), 201);
    }

    public function show(Request $request, Route $route): JsonResponse
    {
        $this->authorize('view', $route);

        return response()->json(new RouteResource($route->load(['schedules', 'stops'])->loadCount('packages')));
    }

    public function update(Request $request, Route $route): JsonResponse
    {
        $this->authorize('update', $route);

        $validated = $request->validate([
            'origin_city' => 'sometimes|string|max:100',
            'origin_country' => 'sometimes|string|max:2',
            'destination_city' => 'sometimes|string|max:100',
            'destination_country' => 'sometimes|string|max:2',
            'departure_date' => 'sometimes|date',
            'estimated_arrival_date' => 'nullable|date',
            'actual_arrival_date' => 'nullable|date',
            'vehicle_info' => 'nullable|array',
            'notes' => 'nullable|string',
        ]);

        $route->update($validated);

        return response()->json(new RouteResource($route->load(['schedules', 'stops'])));
    }

    public function destroy(Request $request, Route $route): JsonResponse
    {
        $this->authorize('delete', $route);

        $route->delete();

        return response()->json(['message' => 'Ruta eliminada correctamente']);
    }

    public function updateStatus(Request $request, Route $route): JsonResponse
    {
        $this->authorize('update', $route);

        $validated = $request->validate([
            'status' => 'required|string|in:'.implode(',', RouteStatus::values()),
        ]);

        $updateData = ['status' => $validated['status']];

        if ($validated['status'] === RouteStatus::COMPLETED->value && ! $route->actual_arrival_date) {
            $updateData['actual_arrival_date'] = now();
        }

        $route->update($updateData);

        return response()->json(new RouteResource($route->load(['schedules', 'stops'])));
    }

    public function packages(Request $request, Route $route): AnonymousResourceCollection
    {
        $this->authorize('view', $route);

        $packages = $route->packages()
            ->with(['route'])
            ->orderBy('created_at', 'desc')
            ->get();

        return PackageResource::collection($packages);
    }

    public function assignPackages(Request $request, Route $route): JsonResponse
    {
        $this->authorize('update', $route);

        $validated = $request->validate([
            'package_ids' => 'required|array',
            'package_ids.*' => 'exists:packages,id',
        ]);

        // Only assign packages that are not delivered or cancelled
        $nonAssignableStatuses = [
            PackageStatus::DELIVERED->value,
            PackageStatus::CANCELLED->value,
        ];

        $updated = Package::whereIn('id', $validated['package_ids'])
            ->where('transporter_id', $request->user()->id)
            ->whereNotIn('status', $nonAssignableStatuses)
            ->update(['route_id' => $route->id]);

        return response()->json([
            'message' => 'Paquetes asignados correctamente',
            'assigned_count' => $updated,
            'route' => new RouteResource($route->load(['schedules', 'stops'])->loadCount('packages')),
        ]);
    }
}
