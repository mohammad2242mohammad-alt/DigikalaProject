<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\ProductIndexRequest;
use App\Http\Requests\StoreProductRequest;
use App\Http\Resources\ProductResource;
use App\Models\Category;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class ProductController extends Controller
{
    public function index(ProductIndexRequest $request): AnonymousResourceCollection
    {
        $filters = $request->validated();
        $query = Product::query()
            ->with(['category', 'seller.sellerProfile'])
            ->where('is_active', true)
            ->where('approval_status', 'approved');

        if (! empty($filters['search'])) {
            $search = $filters['search'];
            $query->where(function ($query) use ($search) {
                $query->where('name', 'like', "%{$search}%")
                    ->orWhere('description', 'like', "%{$search}%");
            });
        }

        if (isset($filters['category_id'])) {
            $categoryId = (int) $filters['category_id'];
            $category = Category::query()->find($categoryId);

            if ($category?->parent_id === null) {
                $childIds = Category::query()
                    ->where('parent_id', $categoryId)
                    ->pluck('id');

                $query->where(function ($query) use ($categoryId, $childIds) {
                    $query->where('category_id', $categoryId)
                        ->orWhereIn('category_id', $childIds);
                });
            } else {
                $query->where('category_id', $categoryId);
            }
        }

        if (isset($filters['min_price'])) {
            $query->whereRaw('COALESCE(discount_price, price) >= ?', [$filters['min_price']]);
        }

        if (isset($filters['max_price'])) {
            $query->whereRaw('COALESCE(discount_price, price) <= ?', [$filters['max_price']]);
        }

        match ($filters['sort'] ?? 'latest') {
            'price_asc' => $query->orderByRaw('COALESCE(discount_price, price) asc'),
            'price_desc' => $query->orderByRaw('COALESCE(discount_price, price) desc'),
            'rating' => $query->orderByDesc('rating'),
            'popular' => $query->orderByDesc('views'),
            default => $query->latest(),
        };

        return ProductResource::collection(
            $query->paginate($filters['per_page'] ?? 20)->withQueryString()
        );
    }

    public function adminIndex(): AnonymousResourceCollection
    {
        return ProductResource::collection(
            Product::query()->with(['category', 'seller.sellerProfile'])->latest()->paginate(30)
        );
    }

    public function store(StoreProductRequest $request): ProductResource
    {
        return new ProductResource(Product::create($request->validated()));
    }

    public function show(Product $product): ProductResource
    {
        abort_unless($product->is_active && $product->approval_status === 'approved', 404);

        $product->increment('views');
        $product->load(['category', 'seller.sellerProfile']);

        return new ProductResource($product->fresh());
    }

    public function update(StoreProductRequest $request, Product $product): ProductResource
    {
        $product->update($request->validated());

        return new ProductResource($product->fresh(['category', 'seller.sellerProfile']));
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
