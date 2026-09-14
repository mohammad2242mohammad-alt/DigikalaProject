<?php

namespace Tests\Feature;

use App\Models\Address;
use App\Models\Product;
use App\Models\Setting;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CheckoutApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_checkout_creates_pending_order_without_decreasing_stock(): void
    {
        Setting::setValue('shipping_price', 50000);
        Setting::setValue('free_shipping_threshold', 1000000);

        $user = User::factory()->create();
        $address = Address::create([
            'user_id' => $user->id,
            'title' => 'خانه',
            'recipient_name' => 'Test User',
            'phone' => '09120000000',
            'province' => 'Yazd',
            'city' => 'Yazd',
            'address' => 'Test address',
            'postal_code' => '1111111111',
            'is_default' => true,
        ]);
        $product = Product::factory()->create([
            'price' => 1000000,
            'discount_price' => 900000,
            'stock' => 3,
            'is_active' => true,
        ]);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/cart/items', [
                'product_id' => $product->id,
                'quantity' => 2,
            ])
            ->assertCreated();

        $checkout = $this->actingAs($user, 'sanctum')
            ->postJson('/api/orders/checkout', [
                'address_id' => $address->id,
            ]);

        $checkout->assertCreated()
            ->assertJsonPath('data.status', 'pending')
            ->assertJsonPath('data.subtotal', '1800000.00')
            ->assertJsonPath('data.total', '1800000.00');

        $this->assertDatabaseHas('products', [
            'id' => $product->id,
            'stock' => 3,
        ]);
        $this->assertDatabaseHas('orders', [
            'user_id' => $user->id,
            'status' => 'pending',
            'total' => 1800000,
        ]);
        $this->assertDatabaseHas('payments', [
            'status' => 'unpaid',
            'amount' => 1800000,
        ]);
    }

    public function test_mock_payment_marks_order_paid_and_decrements_stock(): void
    {
        $user = User::factory()->create();
        $address = Address::create([
            'user_id' => $user->id,
            'recipient_name' => 'Test User',
            'phone' => '09120000000',
            'province' => 'Yazd',
            'city' => 'Yazd',
            'address' => 'Test address',
            'postal_code' => '1111111111',
            'is_default' => true,
        ]);
        $product = Product::factory()->create(['stock' => 2, 'price' => 100000]);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/cart/items', ['product_id' => $product->id, 'quantity' => 1])
            ->assertCreated();

        $orderId = $this->actingAs($user, 'sanctum')
            ->postJson('/api/orders/checkout', ['address_id' => $address->id])
            ->assertCreated()
            ->json('data.id');

        $this->assertDatabaseHas('products', [
            'id' => $product->id,
            'stock' => 2,
        ]);

        $this->actingAs($user, 'sanctum')
            ->postJson("/api/orders/{$orderId}/pay")
            ->assertOk()
            ->assertJsonPath('data.status', 'paid');

        $this->assertDatabaseHas('products', [
            'id' => $product->id,
            'stock' => 1,
        ]);
        $this->assertDatabaseHas('payments', [
            'order_id' => $orderId,
            'status' => 'paid',
        ]);
    }
}
