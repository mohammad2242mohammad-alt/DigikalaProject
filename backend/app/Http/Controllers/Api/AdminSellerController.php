<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\SellerProfileResource;
use App\Models\SellerProfile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class AdminSellerController extends Controller
{
    public function index(): AnonymousResourceCollection
    {
        return SellerProfileResource::collection(
            SellerProfile::query()->with('user')->latest()->paginate(30)
        );
    }

    public function approve(SellerProfile $sellerProfile): SellerProfileResource
    {
        $sellerProfile->update([
            'status' => 'approved',
            'rejection_reason' => null,
        ]);

        return new SellerProfileResource($sellerProfile->fresh());
    }

    public function reject(Request $request, SellerProfile $sellerProfile): SellerProfileResource
    {
        $validated = $request->validate([
            'reason' => ['required', 'string', 'max:2000'],
        ]);

        $sellerProfile->update([
            'status' => 'rejected',
            'rejection_reason' => $validated['reason'],
        ]);

        return new SellerProfileResource($sellerProfile->fresh());
    }

    public function suspend(SellerProfile $sellerProfile): JsonResponse
    {
        $sellerProfile->update(['status' => 'rejected']);
        $sellerProfile->user()->update(['role' => 'buyer']);

        return response()->json([
            'success' => true,
            'message' => 'Seller account suspended.',
            'data' => null,
        ]);
    }
}
