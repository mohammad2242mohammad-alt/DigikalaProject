<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    // نمایش همه محصولات
    public function index()
    {
        return response()->json([
            'products' => Product::all()
        ]);
    }


    // ساخت محصول جدید
    public function store(Request $request)
    {
        $product = Product::create($request->all());

        return response()->json([
            'message' => 'Product created successfully',
            'product' => $product
        ]);
    }


    // نمایش یک محصول
    public function show(string $id)
    {
        $product = Product::findOrFail($id);

        return response()->json($product);
    }


    // ویرایش محصول
    public function update(Request $request, string $id)
    {
        $product = Product::findOrFail($id);

        $product->update($request->all());

        return response()->json([
            'message' => 'Product updated successfully',
            'product' => $product
        ]);
    }


    // حذف محصول
    public function destroy(string $id)
    {
        Product::destroy($id);

        return response()->json([
            'message' => 'Product deleted successfully'
        ]);
    }
}