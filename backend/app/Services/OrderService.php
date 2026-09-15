<?php

namespace App\Services;

use App\Models\Address;
use App\Models\Cart;
use App\Models\Order;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class OrderService
{
    public function __construct(private readonly ShippingService $shippingService)
    {
    }

    public function checkout(int $userId, int $addressId): Order
    {
        return DB::transaction(function () use ($userId, $addressId) {
            $address = Address::query()
                ->where('id', $addressId)
                ->where('user_id', $userId)
                ->firstOrFail();

            $cart = Cart::query()
                ->where('user_id', $userId)
                ->with(['items' => fn ($query) => $query->with('product')])
                ->first();

            if (! $cart || $cart->items->isEmpty()) {
                throw ValidationException::withMessages([
                    'cart' => ['سبد خرید خالی است.'],
                ]);
            }

            $items = [];
            $subtotal = 0.0;

            foreach ($cart->items as $cartItem) {
                $product = $cartItem->product;

                if (! $product || ! $product->is_active) {
                    throw ValidationException::withMessages([
                        'cart' => ['یکی از محصولات سبد خرید دیگر قابل سفارش نیست.'],
                    ]);
                }

                $quantity = (int) $cartItem->quantity;
                $unitPrice = $product->discount_price !== null
                    ? (float) $product->discount_price
                    : (float) $product->price;

                $lineTotal = $unitPrice * $quantity;
                $subtotal += $lineTotal;

                $items[] = [
                    'product' => $product,
                    'quantity' => $quantity,
                    'unit_price' => $unitPrice,
                    'total_price' => $lineTotal,
                ];
            }

            $shipping = $this->shippingService->calculate($subtotal);
            $total = $subtotal + $shipping['shipping_price'];

            $order = Order::create([
                'user_id' => $userId,
                'address_id' => $address->id,
                'recipient_name' => $address->recipient_name,
                'phone' => $address->phone,
                'province' => $address->province,
                'city' => $address->city,
                'address' => $address->address,
                'postal_code' => $address->postal_code,
                'subtotal' => $subtotal,
                'shipping_price' => $shipping['shipping_price'],
                'discount_amount' => 0,
                'total' => $total,
                'status' => 'pending',
            ]);

            foreach ($items as $item) {
                $order->items()->create([
                    'product_id' => $item['product']->id,
                    'seller_id' => $item['product']->seller_id,
                    'product_name' => $item['product']->name,
                    'unit_price' => $item['unit_price'],
                    'quantity' => $item['quantity'],
                    'total_price' => $item['total_price'],
                    'fulfillment_status' => 'pending',
                ]);
            }

            $order->payments()->create([
                'method' => 'mock',
                'status' => 'unpaid',
                'amount' => $total,
            ]);

            $cart->items()->delete();

            return $order->load(['items', 'payments']);
        });
    }
}
