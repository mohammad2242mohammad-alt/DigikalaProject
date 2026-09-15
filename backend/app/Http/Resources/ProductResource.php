<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProductResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'category_id' => $this->category_id,
            'seller_id' => $this->seller_id,
            'seller' => $this->whenLoaded('seller', function () {
                return $this->seller ? [
                    'id' => $this->seller->id,
                    'name' => $this->seller->sellerProfile?->store_name ?? $this->seller->name,
                    'slug' => $this->seller->sellerProfile?->slug,
                    'status' => $this->seller->sellerProfile?->status,
                ] : null;
            }),
            'name' => $this->name,
            'description' => $this->description,
            'price' => (float) $this->price,
            'discount_price' => $this->discount_price !== null ? (float) $this->discount_price : null,
            'image' => $this->image,
            'stock' => $this->stock,
            'is_active' => (bool) $this->is_active,
            'approval_status' => $this->approval_status,
            'rejection_reason' => $this->rejection_reason,
            'rating' => (float) $this->rating,
            'views' => $this->views,
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
