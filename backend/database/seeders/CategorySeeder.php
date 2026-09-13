<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            ['name' => 'موبایل', 'slug' => 'mobile', 'sort_order' => 1],
            ['name' => 'کالای دیجیتال', 'slug' => 'digital-goods', 'sort_order' => 2],
            ['name' => 'لپ‌تاپ و کامپیوتر', 'slug' => 'laptop-computer', 'sort_order' => 3],
            ['name' => 'هدفون و هندزفری', 'slug' => 'headphones', 'sort_order' => 4],
            ['name' => 'خانه و آشپزخانه', 'slug' => 'home-kitchen', 'sort_order' => 5],
        ];

        foreach ($categories as $category) {
            Category::updateOrCreate(
                ['slug' => $category['slug']],
                $category + ['is_active' => true]
            );
        }
    }
}
