<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\AddCartItemRequest;
use App\Http\Requests\UpdateCartItemRequest;
use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CartController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => 'Cart retrieved successfully.',
            'data' => $this->cartFor($request->user()),
        ]);
    }

    public function store(AddCartItemRequest $request): JsonResponse
    {
        $product = Product::query()
            ->where('id', $request->validated('product_id'))
            ->where('is_active', true)
            ->firstOrFail();

        $cart = Cart::firstOrCreate(['user_id' => $request->user()->id]);
        $item = $cart->items()->firstOrNew(['product_id' => $product->id]);
        $quantity = ($item->exists ? $item->quantity : 0) + ($request->validated('quantity') ?? 1);

        abort_if($product->stock < $quantity, 422, 'Requested quantity is not available in stock.');

        $item->quantity = $quantity;
        $item->save();

        return response()->json([
            'success' => true,
            'message' => 'Product added to cart.',
            'data' => $this->cartFor($request->user()),
        ], 201);
    }

    public function update(UpdateCartItemRequest $request, CartItem $cartItem): JsonResponse
    {
        $this->ensureOwnership($request, $cartItem);
        abort_if(! $cartItem->product->is_active, 422, 'Product is not available.');
        abort_if($cartItem->product->stock < $request->validated('quantity'), 422, 'Requested quantity is not available in stock.');

        $cartItem->update(['quantity' => $request->validated('quantity')]);

        return response()->json([
            'success' => true,
            'message' => 'Cart updated successfully.',
            'data' => $this->cartFor($request->user()),
        ]);
    }

    public function destroy(Request $request, CartItem $cartItem): JsonResponse
    {
        $this->ensureOwnership($request, $cartItem);
        $cartItem->delete();

        return response()->json([
            'success' => true,
            'message' => 'Cart item removed.',
            'data' => $this->cartFor($request->user()),
        ]);
    }

    public function clear(Request $request): JsonResponse
    {
        $cart = Cart::where('user_id', $request->user()->id)->first();
        $cart?->items()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Cart cleared successfully.',
            'data' => $this->cartFor($request->user()),
        ]);
    }

    private function ensureOwnership(Request $request, CartItem $cartItem): void
    {
        abort_unless($cartItem->cart->user_id === $request->user()->id, 403);
    }

    private function cartFor($user): array
    {
        $cart = Cart::query()
            ->firstOrCreate(['user_id' => $user->id]);

        $cart->load(['items.product' => fn ($query) => $query->where('is_active', true)]);

        $items = $cart->items->filter(fn (CartItem $item) => $item->product !== null)->values();
        $subtotal = $items->sum(function (CartItem $item) {
            $unitPrice = $item->product->discount_price ?? $item->product->price;
            return (float) $unitPrice * $item->quantity;
        });

        return [
            'id' => $cart->id,
            'items' => $items->map(fn (CartItem $item) => [
                'id' => $item->id,
                'product' => $item->product,
                'quantity' => $item->quantity,
                'unit_price' => (float) ($item->product->discount_price ?? $item->product->price),
                'total_price' => (float) ($item->product->discount_price ?? $item->product->price) * $item->quantity,
            ])->values(),
            'subtotal' => (float) $subtotal,
            'items_count' => $items->sum('quantity'),
        ];
    }
}
