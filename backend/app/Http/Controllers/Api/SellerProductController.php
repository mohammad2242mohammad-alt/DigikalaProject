<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\SellerProductRequest;
use App\Http\Resources\ProductResource;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class SellerProductController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $this->authorizeSeller($request);

        return ProductResource::collection(
            Product::query()
                ->with('category')
                ->where('seller_id', $request->user()->id)
                ->latest()
                ->paginate(30)
        );
    }

    public function store(SellerProductRequest $request): ProductResource
    {
        $product = Product::create([
            ...$request->validated(),
            'seller_id' => $request->user()->id,
            'is_active' => false,
            'approval_status' => 'pending',
        ]);

        return new ProductResource($product->load('category'));
    }

    public function show(Request $request, Product $product): ProductResource
    {
        $this->authorizeSellerProduct($request, $product);

        return new ProductResource($product->load('category'));
    }

    public function update(SellerProductRequest $request, Product $product): ProductResource
    {
        $this->authorizeSellerProduct($request, $product);

        $product->update([
            ...$request->validated(),
            'is_active' => false,
            'approval_status' => 'pending',
            'rejection_reason' => null,
        ]);

        return new ProductResource($product->fresh('category'));
    }

    public function destroy(Request $request, Product $product): JsonResponse
    {
        $this->authorizeSellerProduct($request, $product);
        $product->delete();

        return response()->json([
            'success' => true,
            'message' => 'Product deleted successfully.',
            'data' => null,
        ]);
    }

    private function authorizeSeller(Request $request): void
    {
        abort_unless($request->user()?->isSeller(), 403);
    }

    private function authorizeSellerProduct(Request $request, Product $product): void
    {
        $this->authorizeSeller($request);
        abort_unless($product->seller_id === $request->user()->id, 403);
    }
}
