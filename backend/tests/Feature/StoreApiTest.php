<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Product;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class StoreApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_public_product_catalog_returns_active_products(): void
    {
        Product::factory()->create([
            'name' => 'Active product',
            'is_active' => true,
        ]);
        Product::factory()->create([
            'name' => 'Hidden product',
            'is_active' => false,
        ]);

        $response = $this->getJson('/api/products');

        $response->assertOk()
            ->assertJsonPath('data.0.name', 'Active product')
            ->assertJsonMissing(['name' => 'Hidden product']);
    }

    public function test_product_catalog_can_filter_by_search_and_price(): void
    {
        Product::factory()->create([
            'name' => 'Budget phone',
            'price' => 500000,
            'discount_price' => null,
            'is_active' => true,
        ]);
        Product::factory()->create([
            'name' => 'Premium phone',
            'price' => 2000000,
            'discount_price' => 1500000,
            'is_active' => true,
        ]);

        $response = $this->getJson('/api/products?search=Premium&max_price=1600000');

        $response->assertOk()
            ->assertJsonPath('data.0.name', 'Premium phone');
    }

    public function test_authenticated_user_can_register_and_get_profile(): void
    {
        $register = $this->postJson('/api/auth/register', [
            'name' => 'Test User',
            'email' => 'store-api@example.com',
            'password' => 'password',
            'password_confirmation' => 'password',
        ]);

        $register->assertCreated();

        $token = $register->json('data.token');

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/auth/me')
            ->assertOk()
            ->assertJsonPath('data.email', 'store-api@example.com');
    }

    public function test_authenticated_user_can_add_product_to_cart(): void
    {
        $user = User::factory()->create();
        $category = Category::factory()->create();
        $product = Product::factory()->create([
            'category_id' => $category->id,
            'price' => 1000000,
            'stock' => 5,
            'is_active' => true,
        ]);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/cart/items', [
                'product_id' => $product->id,
                'quantity' => 2,
            ])
            ->assertCreated()
            ->assertJsonPath('data.items.0.quantity', 2)
            ->assertJsonPath('data.items.0.product.id', $product->id);
    }
}
