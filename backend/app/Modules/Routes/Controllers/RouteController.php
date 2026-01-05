<?php

namespace App\Modules\Routes\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Packages\Models\Package;
use App\Modules\Routes\Models\Route;
use App\Modules\Routes\Models\RouteSchedule;
use App\Modules\Routes\Resources\RouteResource;
use Carbon\Carbon;
use App\Shared\Enums\RouteStatus;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class RouteController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = Route::forTransporter($request->user()->id)
            ->with('schedules')
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

        $routes = $query->orderBy('departure_date', 'desc')
            ->paginate($request->per_page ?? 15);

        return RouteResource::collection($routes);
    }

    public function store(Request $request): JsonResponse
    {
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
        ]);

        $validated['transporter_id'] = $request->user()->id;
        $validated['status'] = RouteStatus::PLANNED->value;

        // Get departure dates (support both formats)
        $departureDates = $validated['departure_dates'] ?? [$validated['departure_date']];
        $tripDurationHours = $validated['trip_duration_hours'] ?? null;

        // Set the first departure date as the main route date (for backward compatibility)
        $firstDate = collect($departureDates)->sort()->first();
        $validated['departure_date'] = $firstDate;

        if ($tripDurationHours && !isset($validated['estimated_arrival_date'])) {
            $validated['estimated_arrival_date'] = Carbon::parse($firstDate)->addHours($tripDurationHours);
        }

        // Remove array fields before creating route
        unset($validated['departure_dates'], $validated['trip_duration_hours']);

        $route = Route::create($validated);

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

        return response()->json(new RouteResource($route->load('schedules')), 201);
    }

    public function show(Request $request, Route $route): JsonResponse
    {
        $this->authorize('view', $route);

        return response()->json(new RouteResource($route->load('schedules')->loadCount('packages')));
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

        return response()->json(new RouteResource($route));
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

        return response()->json(new RouteResource($route));
    }

    public function packages(Request $request, Route $route): JsonResponse
    {
        $this->authorize('view', $route);

        $packages = $route->packages()
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($packages);
    }

    public function assignPackages(Request $request, Route $route): JsonResponse
    {
        $this->authorize('update', $route);

        $validated = $request->validate([
            'package_ids' => 'required|array',
            'package_ids.*' => 'exists:packages,id',
        ]);

        Package::whereIn('id', $validated['package_ids'])
            ->where('transporter_id', $request->user()->id)
            ->update(['route_id' => $route->id]);

        return response()->json([
            'message' => 'Paquetes asignados correctamente',
            'route' => new RouteResource($route->loadCount('packages')),
        ]);
    }
}
