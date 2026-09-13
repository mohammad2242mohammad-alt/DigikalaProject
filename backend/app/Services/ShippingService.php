<?php

namespace App\Services;

use App\Models\Setting;

class ShippingService
{
    public function calculate(float $subtotal): array
    {
        $shippingPrice = (float) Setting::getValue('shipping_price', 0);
        $freeThreshold = (float) Setting::getValue('free_shipping_threshold', 0);
        $isFree = $freeThreshold > 0 && $subtotal >= $freeThreshold;

        return [
            'shipping_price' => $isFree ? 0.0 : $shippingPrice,
            'is_free' => $isFree,
            'free_shipping_threshold' => $freeThreshold,
        ];
    }
}
