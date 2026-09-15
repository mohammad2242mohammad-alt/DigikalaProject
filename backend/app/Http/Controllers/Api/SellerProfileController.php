<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreSellerProfileRequest;
use App\Http\Resources\SellerProfileResource;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class SellerProfileController extends Controller
{
    public function show(Request $request): SellerProfileResource
    {
        $profile = $request->user()->sellerProfile;

        abort_unless($profile, 404, 'Seller profile not found.');

        return new SellerProfileResource($profile);
    }

    public function store(StoreSellerProfileRequest $request): SellerProfileResource
    {
        $user = $request->user();
        abort_if($user->sellerProfile, 422, 'Seller profile already exists.');

        $data = $request->validated();
        $baseSlug = Str::slug($data['store_name']);
        $slug = $baseSlug ?: 'seller-'.$user->id;
        $suffix = 1;

        while (\App\Models\SellerProfile::where('slug', $slug)->exists()) {
            $slug = $baseSlug.'-'.$suffix++;
        }

        $profile = $user->sellerProfile()->create([
            ...$data,
            'slug' => $slug,
            'status' => 'pending',
        ]);

        return new SellerProfileResource($profile);
    }

    public function update(StoreSellerProfileRequest $request): SellerProfileResource
    {
        $profile = $request->user()->sellerProfile;
        abort_unless($profile, 404, 'Seller profile not found.');

        $profile->update($request->validated());

        return new SellerProfileResource($profile->fresh());
    }
}
