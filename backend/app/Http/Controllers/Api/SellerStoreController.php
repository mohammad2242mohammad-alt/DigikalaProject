<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ProductResource;
use App\Http\Resources\SellerProfileResource;
use App\Models\SellerProfile;
use Illuminate\Http\JsonResponse;

class SellerStoreController extends Controller
{
    public function show(SellerProfile $sellerProfile): JsonResponse
    {
        abort_unless($sellerProfile->status === 'approved', 404);

        $sellerProfile->load([
            'user',
            'products' => fn ($query) => $query
                ->with(['category', 'seller.sellerProfile'])
                ->where('is_active', true)
                ->where('approval_status', 'approved')
                ->latest(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Seller store retrieved successfully.',
            'data' => [
                'seller' => new SellerProfileResource($sellerProfile),
                'products' => ProductResource::collection($sellerProfile->products),
            ],
        ]);
    }
}
