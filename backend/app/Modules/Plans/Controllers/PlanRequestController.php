<?php

namespace App\Modules\Plans\Controllers;

use App\Modules\Plans\Models\PlanRequest;
use App\Modules\Plans\Requests\StorePlanRequestRequest;
use App\Modules\Plans\Resources\PlanRequestResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Routing\Controller;

class PlanRequestController extends Controller
{
    public function store(StorePlanRequestRequest $request): PlanRequestResource
    {
        $planRequest = PlanRequest::updateOrCreate(
            [
                'user_id' => $request->user()->id,
                'status' => 'pending',
            ],
            $request->validated(),
        );

        return new PlanRequestResource($planRequest->load('user'));
    }

    public function index(): AnonymousResourceCollection
    {
        $planRequests = PlanRequest::with('user')
            ->where('status', 'pending')
            ->latest()
            ->paginate(50);

        return PlanRequestResource::collection($planRequests);
    }

    public function myRequest(Request $request): JsonResponse
    {
        $planRequest = PlanRequest::where('user_id', $request->user()->id)
            ->where('status', 'pending')
            ->first();

        if (! $planRequest) {
            return response()->json(['data' => null]);
        }

        return response()->json([
            'data' => new PlanRequestResource($planRequest),
        ]);
    }

    public function approve(PlanRequest $planRequest): PlanRequestResource
    {
        abort_unless($planRequest->status === 'pending', 422, 'Only pending requests can be approved.');

        $planRequest->update(['status' => 'approved']);
        $planRequest->user->update(['active_plan_key' => $planRequest->plan_key]);

        return new PlanRequestResource($planRequest->load('user'));
    }

    public function reject(PlanRequest $planRequest): PlanRequestResource
    {
        abort_unless($planRequest->status === 'pending', 422, 'Only pending requests can be rejected.');

        $planRequest->update(['status' => 'rejected']);

        return new PlanRequestResource($planRequest->load('user'));
    }
}
