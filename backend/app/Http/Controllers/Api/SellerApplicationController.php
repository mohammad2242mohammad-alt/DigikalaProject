<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SellerProfile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class SellerApplicationController extends Controller
{
    public function apply(Request $request): JsonResponse
    {
        $user = $request->user();

        abort_if($user->isAdmin(), 422, 'Administrators cannot apply as sellers.');
        abort_if($user->isSeller(), 422, 'User is already a seller.');

        $validated = $request->validate([
            'store_name' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string', 'max:5000'],
            'logo' => ['nullable', 'string', 'max:2048'],
        ]);

        $baseSlug = Str::slug($validated['store_name']);
        $slug = $baseSlug ?: 'seller-'.$user->id;
        $suffix = 1;

        while (SellerProfile::where('slug', $slug)->exists()) {
            $slug = $baseSlug.'-'.$suffix++;
        }

        $user->update(['role' => 'seller']);
        $profile = $user->sellerProfile()->create([
            ...$validated,
            'slug' => $slug,
            'status' => 'pending',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Seller application submitted and is awaiting approval.',
            'data' => $profile,
        ], 201);
    }
}
