<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Favorite;
use App\Models\Product;
use Illuminate\Http\Request;

class FavoriteController extends Controller
{
    public function index(Request $request)
    {
        return response()->json([
            'success' => true,
            'message' => 'علاقه‌مندی‌ها دریافت شد.',
            'data' => $request->user()->favorites()->with('product')->latest()->get(),
        ]);
    }

    public function store(Request $request, Product $product)
    {
        if (!$product->is_active) {
            return response()->json(['success' => false, 'message' => 'این محصول فعال نیست.'], 422);
        }

        $favorite = Favorite::firstOrCreate([
            'user_id' => $request->user()->id,
            'product_id' => $product->id,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'محصول به علاقه‌مندی‌ها اضافه شد.',
            'data' => $favorite->load('product'),
        ], 201);
    }

    public function destroy(Request $request, Product $product)
    {
        $deleted = Favorite::where('user_id', $request->user()->id)
            ->where('product_id', $product->id)
            ->delete();

        return response()->json([
            'success' => true,
            'message' => $deleted ? 'محصول از علاقه‌مندی‌ها حذف شد.' : 'محصول در علاقه‌مندی‌ها نبود.',
            'data' => null,
        ]);
    }
}
