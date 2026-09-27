<?php

namespace App\Http\Controllers;

use App\Models\Category;
use Illuminate\Http\JsonResponse;

class CategoryController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json([
            'categories' => Category::whereNull('parent_id')->with('children')->orderBy('name')->get(),
        ]);
    }
}
