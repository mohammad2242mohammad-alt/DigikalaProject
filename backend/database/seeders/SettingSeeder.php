<?php

namespace Database\Seeders;

use App\Models\Setting;
use Illuminate\Database\Seeder;

class SettingSeeder extends Seeder
{
    public function run(): void
    {
        Setting::setValue('shipping_price', 50000);
        Setting::setValue('free_shipping_threshold', 1000000);
    }
}
