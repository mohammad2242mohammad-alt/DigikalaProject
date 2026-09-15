<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Product;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    public function run(): void
    {
        $mobileCategoryId = Category::where('slug', 'mobile-phones')->value('id');
        $laptopCategoryId = Category::where('slug', 'laptops')->value('id');
        $headphonesCategoryId = Category::where('slug', 'headphones-main')->value('id');

        $products = [
            [
                'category_id' => $mobileCategoryId,
                'name' => 'گوشی موبایل سامسونگ Galaxy A55',
                'description' => 'گوشی میان رده سامسونگ',
                'price' => 18500000,
                'discount_price' => 16900000,
                'image' => 'products/a55.jpg',
                'stock' => 20,
                'is_active' => true,
                'rating' => 4.5,
                'views' => 120,
            ],
            [
                'category_id' => $laptopCategoryId,
                'name' => 'لپ تاپ ASUS VivoBook',
                'description' => 'لپ تاپ مناسب کار و دانشجویی',
                'price' => 32000000,
                'discount_price' => 29900000,
                'image' => 'products/asus.jpg',
                'stock' => 10,
                'is_active' => true,
                'rating' => 4.3,
                'views' => 80,
            ],
            [
                'category_id' => $headphonesCategoryId,
                'name' => 'هدفون بی سیم',
                'description' => 'هدفون بلوتوثی با کیفیت',
                'price' => 2500000,
                'discount_price' => 1990000,
                'image' => 'products/headphone.jpg',
                'stock' => 50,
                'is_active' => true,
                'rating' => 4.7,
                'views' => 300,
            ],
        ];

        foreach ($products as $product) {
            Product::updateOrCreate(
                ['name' => $product['name']],
                $product,
            );
        }
    }
}
