<?php

use App\Http\Controllers\Api\AddressController;
use App\Http\Controllers\Api\AdminSellerController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CartController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\FavoriteController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\PaymentController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\SellerApplicationController;
use App\Http\Controllers\Api\SellerOrderController;
use App\Http\Controllers\Api\SellerProductController;
use App\Http\Controllers\Api\SellerProfileController;
use Illuminate\Support\Facades\Route;

Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/logout', [AuthController::class, 'logout']);
    });
});

Route::get('/categories', [CategoryController::class, 'index']);
Route::get('/categories/{category}', [CategoryController::class, 'show']);
Route::get('/products', [ProductController::class, 'index']);
Route::get('/products/{product}', [ProductController::class, 'show']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/seller/apply', [SellerApplicationController::class, 'apply']);

    Route::get('/cart', [CartController::class, 'show']);
    Route::post('/cart/items', [CartController::class, 'store']);
    Route::patch('/cart/items/{cartItem}', [CartController::class, 'update']);
    Route::delete('/cart/items/{cartItem}', [CartController::class, 'destroy']);
    Route::delete('/cart', [CartController::class, 'clear']);

    Route::apiResource('addresses', AddressController::class)->except(['show']);

    Route::get('/favorites', [FavoriteController::class, 'index']);
    Route::post('/favorites/{product}', [FavoriteController::class, 'store']);
    Route::delete('/favorites/{product}', [FavoriteController::class, 'destroy']);

    Route::get('/orders', [OrderController::class, 'index']);
    Route::post('/orders/checkout', [OrderController::class, 'checkout']);
    Route::get('/orders/{order}', [OrderController::class, 'show']);
    Route::post('/orders/{order}/pay', [PaymentController::class, 'pay']);

    Route::middleware('can:seller')->prefix('seller')->group(function () {
        Route::get('/profile', [SellerProfileController::class, 'show']);
        Route::post('/profile', [SellerProfileController::class, 'store']);
        Route::put('/profile', [SellerProfileController::class, 'update']);
        Route::patch('/profile', [SellerProfileController::class, 'update']);

        Route::apiResource('products', SellerProductController::class);
        Route::get('/orders', [SellerOrderController::class, 'index']);
        Route::get('/orders/{orderItem}', [SellerOrderController::class, 'show']);
        Route::patch('/orders/{orderItem}/status', [SellerOrderController::class, 'updateStatus']);
    });

    Route::middleware('can:admin')->group(function () {
        Route::get('/admin/products', [ProductController::class, 'adminIndex']);
        Route::post('/products', [ProductController::class, 'store']);
        Route::put('/products/{product}', [ProductController::class, 'update']);
        Route::patch('/products/{product}', [ProductController::class, 'update']);
        Route::delete('/products/{product}', [ProductController::class, 'destroy']);

        Route::get('/admin/categories', [CategoryController::class, 'adminIndex']);
        Route::post('/categories', [CategoryController::class, 'store']);
        Route::put('/categories/{category}', [CategoryController::class, 'update']);
        Route::patch('/categories/{category}', [CategoryController::class, 'update']);
        Route::delete('/categories/{category}', [CategoryController::class, 'destroy']);

        Route::get('/admin/orders', [OrderController::class, 'adminIndex']);
        Route::patch('/admin/orders/{order}/status', [OrderController::class, 'adminUpdateStatus']);

        Route::get('/admin/sellers', [AdminSellerController::class, 'index']);
        Route::patch('/admin/sellers/{sellerProfile}/approve', [AdminSellerController::class, 'approve']);
        Route::patch('/admin/sellers/{sellerProfile}/reject', [AdminSellerController::class, 'reject']);
        Route::patch('/admin/sellers/{sellerProfile}/suspend', [AdminSellerController::class, 'suspend']);
    });
});
