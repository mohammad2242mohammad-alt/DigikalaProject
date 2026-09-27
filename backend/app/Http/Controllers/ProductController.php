<?php

namespace App\Http\Controllers;

use App\Http\Requests\ProductIndexRequest;
use App\Models\Product;
use Illuminate\Http\JsonResponse;

class ProductController extends Controller
{
    public function index(ProductIndexRequest $request): JsonResponse
    {
        $query = Product::query()->where('is_active', true);

        if ($request->filled('search')) {
            $search = trim((string) $request->input('search'));
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('description', 'like', "%{$search}%");
            });
        }

        if ($request->filled('category_id')) {
            $categoryId = (int) $request->input('category_id');
            $query->where(function ($q) use ($categoryId) {
                $q->where('category_id', $categoryId)
                    ->orWhereHas('category', fn ($category) => $category->where('parent_id', $categoryId));
            });
        }

        \$price = 'CASE WHEN discount_price > 0 AND discount_price < price THEN discount_price ELSE price END';

        if ($request->filled('min_price')) {
            $query->whereRaw("\$price >= ?", [$request->input('min_price')]);
        }

        if ($request->filled('max_price')) {
            $query->whereRaw("\$price <= ?", [$request->input('max_price')]);
        }

        match ($request->input('sort', 'latest')) {
            'price_asc' => $query->orderByRaw("\$price ASC"),
            'price_desc' => $query->orderByRaw("\$price DESC"),
            'rating' => $query->orderByDesc('rating'),
            'popular' => $query->orderByDesc('views'),
            default => $query->latest(),
        };

        $products = $query->paginate((int) $request->input('per_page', 20));

        return response()->json([
            'products' => $products->items(),
            'meta' => [
                'current_page' => $products->currentPage(),
                'last_page' => $products->lastPage(),
                'total' => $products->total(),
            ],
        ]);
    }
}
