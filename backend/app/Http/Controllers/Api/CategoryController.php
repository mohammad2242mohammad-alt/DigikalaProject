<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    public function index(): JsonResponse
    {
        $categories = Category::query()
            ->where('is_active', true)
            ->whereNull('parent_id')
            ->with(['children' => fn ($query) => $query->where('is_active', true)])
            ->orderBy('sort_order')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Categories retrieved successfully.',
            'data' => $categories,
        ]);
    }

    public function show(Category $category): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => 'Category retrieved successfully.',
            'data' => $category->load('children'),
        ]);
    }
}
