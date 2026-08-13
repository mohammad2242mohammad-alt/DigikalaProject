<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    protected $fillable = [
        'name',
        'description',
        'price',
        'discount_price',
        'image',
        'stock',
        'is_active',
        'rating',
        'views',
    ];
}