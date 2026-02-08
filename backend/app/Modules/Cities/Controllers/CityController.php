<?php

namespace App\Modules\Cities\Controllers;

use App\Modules\Cities\Models\City;
use App\Modules\Cities\Requests\CitySearchRequest;
use App\Modules\Cities\Resources\CityResource;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Routing\Controller;

class CityController extends Controller
{
    public function search(CitySearchRequest $request): AnonymousResourceCollection
    {
        $query = trim($request->input('q', ''));
        $limit = (int) $request->input('limit', 20);

        if (mb_strlen($query) < 1) {
            return CityResource::collection(collect());
        }

        $builder = City::query()->search($query);

        if ($request->filled('countries')) {
            $countries = array_map('trim', explode(',', $request->input('countries')));
            $builder->forCountries($countries);
        }

        $builder->orderByDesc('population')
            ->limit($limit);

        return CityResource::collection($builder->get());
    }
}
