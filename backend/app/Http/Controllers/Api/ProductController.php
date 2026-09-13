<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreProductRequest;
use App\Http\Resources\ProductResource;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class ProductController extends Controller
{
    public function index(): AnonymousResourceCollection
    {
        $products = Product::query()
            ->with('category')
            ->where('is_active', true)
            ->latest()
            ->paginate(20);

        return ProductResource::collection($products);
    }

    public function store(StoreProductRequest $request): ProductResource
    {
        return new ProductResource(Product::create($request->validated()));
    }

    public function show(Product $product): ProductResource
    {
        abort_unless($product->is_active, 404);

        $product->increment('views');
        $product->load('category');

        return new ProductResource($product->fresh());
    }

    public function update(StoreProductRequest $request, Product $product): ProductResource
    {
        $product->update($request->validated());

        return new ProductResource($product->fresh('category'));
    }

    public function destroy(Product $product): JsonResponse
    {
        $product->delete();

        return response()->json([
            'success' => true,
            'message' => 'Product deleted successfully.',
            'data' => null,
        ]);
    }
}
