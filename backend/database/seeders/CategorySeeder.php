<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            [
                'name' => 'موبایل',
                'slug' => 'mobile',
                'sort_order' => 1,
                'children' => [
                    ['name' => 'گوشی موبایل', 'slug' => 'mobile-phones', 'sort_order' => 1],
                    ['name' => 'تبلت', 'slug' => 'tablets', 'sort_order' => 2],
                    ['name' => 'لوازم جانبی موبایل', 'slug' => 'mobile-accessories', 'sort_order' => 3],
                ],
            ],
            [
                'name' => 'کالای دیجیتال',
                'slug' => 'digital-goods',
                'sort_order' => 2,
                'children' => [
                    ['name' => 'مانیتور', 'slug' => 'monitors', 'sort_order' => 1],
                    ['name' => 'دوربین', 'slug' => 'cameras', 'sort_order' => 2],
                    ['name' => 'لوازم جانبی کامپیوتر', 'slug' => 'computer-accessories', 'sort_order' => 3],
                ],
            ],
            [
                'name' => 'لپ‌تاپ و کامپیوتر',
                'slug' => 'laptop-computer',
                'sort_order' => 3,
                'children' => [
                    ['name' => 'لپ‌تاپ', 'slug' => 'laptops', 'sort_order' => 1],
                    ['name' => 'کامپیوتر رومیزی', 'slug' => 'desktop-computers', 'sort_order' => 2],
                    ['name' => 'قطعات کامپیوتر', 'slug' => 'pc-parts', 'sort_order' => 3],
                ],
            ],
            [
                'name' => 'هدفون و هندزفری',
                'slug' => 'headphones',
                'sort_order' => 4,
                'children' => [
                    ['name' => 'هدفون', 'slug' => 'headphones-main', 'sort_order' => 1],
                    ['name' => 'هندزفری بی‌سیم', 'slug' => 'wireless-earbuds', 'sort_order' => 2],
                    ['name' => 'هندزفری سیمی', 'slug' => 'wired-earphones', 'sort_order' => 3],
                ],
            ],
            [
                'name' => 'خانه و آشپزخانه',
                'slug' => 'home-kitchen',
                'sort_order' => 5,
                'children' => [
                    ['name' => 'لوازم برقی آشپزخانه', 'slug' => 'kitchen-appliances', 'sort_order' => 1],
                    ['name' => 'لوازم خانه', 'slug' => 'home-appliances', 'sort_order' => 2],
                    ['name' => 'ظروف و ابزار آشپزخانه', 'slug' => 'kitchen-tools', 'sort_order' => 3],
                ],
            ],
        ];

        foreach ($categories as $categoryData) {
            $children = $categoryData['children'];
            unset($categoryData['children']);

            $parent = Category::updateOrCreate(
                ['slug' => $categoryData['slug']],
                $categoryData + ['is_active' => true]
            );

            foreach ($children as $childData) {
                Category::updateOrCreate(
                    ['slug' => $childData['slug']],
                    $childData + [
                        'parent_id' => $parent->id,
                        'is_active' => true,
                    ]
                );
            }
        }
    }
}
