<?php

namespace Database\Factories;

use App\Models\Category;
use App\Models\Product;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Product>
 */
class ProductFactory extends Factory
{
    protected $model = Product::class;

    public function definition(): array
    {
        $price = fake()->numberBetween(100_000, 10_000_000);

        return [
            'category_id' => Category::factory(),
            'name' => fake()->unique()->words(3, true),
            'description' => fake()->optional()->paragraph(),
            'price' => $price,
            'discount_price' => null,
            'image' => null,
            'stock' => fake()->numberBetween(1, 100),
            'is_active' => true,
            'rating' => fake()->randomFloat(1, 0, 5),
            'views' => 0,
        ];
    }

    public function inactive(): static
    {
        return $this->state(fn () => ['is_active' => false]);
    }

    public function outOfStock(): static
    {
        return $this->state(fn () => ['stock' => 0]);
    }
}
