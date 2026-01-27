<?php

namespace App\Modules\Routes\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Routes\Models\Route;
use App\Modules\Routes\Resources\RouteResource;
use App\Modules\Trips\Controllers\TripController;
use App\Modules\Trips\Resources\TripResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class RouteController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = Route::forTransporter($request->user()->id)
            ->with(['stops'])
            ->withCount('trips');

        if ($request->boolean('active_only')) {
            $query->active();
        }

        $perPage = min($request->integer('per_page', 15), 100);

        $routes = $query->orderBy('created_at', 'desc')
            ->paginate($perPage);

        return RouteResource::collection($routes);
    }

    public function store(Request $request): JsonResponse
    {
        $this->authorize('create', Route::class);

        $validated = $request->validate([
            'name' => 'nullable|string|max:200',
            'description' => 'nullable|string|max:1000',
            'estimated_duration_hours' => 'nullable|integer|min:1',
            'origin_city' => 'required|string|max:100',
            'origin_country' => 'required|string|max:2',
            'destination_city' => 'required|string|max:100',
            'destination_country' => 'required|string|max:2',
            'vehicle_info' => 'nullable|array',
            'notes' => 'nullable|string|max:1000',
            'price_per_kg' => 'nullable|numeric|min:0|max:9999.99',
            'minimum_price' => 'nullable|numeric|min:0|max:9999.99',
            'price_multiplier' => 'nullable|numeric|min:0.1|max:10',
            'stops' => 'nullable|array',
            'stops.*.city' => 'required_with:stops|string|max:100',
            'stops.*.country' => 'required_with:stops|string|max:2',
            'stops.*.order' => 'nullable|integer|min:0',
        ]);

        $validated['transporter_id'] = $request->user()->id;
        $validated['is_active'] = true;

        $stops = $validated['stops'] ?? [];
        unset($validated['stops']);

        $route = Route::create($validated);

        foreach ($stops as $index => $stopData) {
            $route->stops()->create([
                'city' => $stopData['city'],
                'country' => $stopData['country'],
                'order' => $stopData['order'] ?? $index,
            ]);
        }

        return response()->json(new RouteResource($route->load('stops')), 201);
    }

    public function show(Request $request, Route $route): JsonResponse
    {
        $this->authorize('view', $route);

        return response()->json(new RouteResource($route->load('stops')->loadCount('trips')));
    }

    public function update(Request $request, Route $route): JsonResponse
    {
        $this->authorize('update', $route);

        $validated = $request->validate([
            'name' => 'sometimes|string|max:200',
            'description' => 'nullable|string|max:1000',
            'is_active' => 'sometimes|boolean',
            'estimated_duration_hours' => 'nullable|integer|min:1',
            'origin_city' => 'sometimes|string|max:100',
            'origin_country' => 'sometimes|string|max:2',
            'destination_city' => 'sometimes|string|max:100',
            'destination_country' => 'sometimes|string|max:2',
            'vehicle_info' => 'nullable|array',
            'notes' => 'nullable|string|max:1000',
            'price_per_kg' => 'nullable|numeric|min:0|max:9999.99',
            'minimum_price' => 'nullable|numeric|min:0|max:9999.99',
            'price_multiplier' => 'nullable|numeric|min:0.1|max:10',
        ]);

        $route->update($validated);

        return response()->json(new RouteResource($route->load('stops')));
    }

    public function destroy(Request $request, Route $route): JsonResponse
    {
        $this->authorize('delete', $route);

        $route->delete();

        return response()->json(['message' => 'Plantilla de ruta eliminada correctamente']);
    }

    public function trips(Request $request, Route $route): AnonymousResourceCollection
    {
        $this->authorize('view', $route);

        $trips = $route->trips()
            ->with(['stops'])
            ->withCount('packages')
            ->orderBy('departure_date', 'desc')
            ->get();

        return TripResource::collection($trips);
    }

    public function createTrip(Request $request, Route $route): JsonResponse
    {
        return app(TripController::class)->storeFromRoute($request, $route);
    }
}
