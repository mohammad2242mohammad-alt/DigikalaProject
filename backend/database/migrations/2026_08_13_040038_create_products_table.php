<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('products', function (Blueprint $table) {

            $table->id();

            // اطلاعات اصلی محصول
            $table->string('name');
            $table->text('description')->nullable();

            // قیمت و تخفیف
            $table->decimal('price', 12, 2);
            $table->decimal('discount_price', 12, 2)->nullable();

            // تصویر محصول
            $table->string('image')->nullable();

            // موجودی
            $table->integer('stock')->default(0);

            // وضعیت محصول
            $table->boolean('is_active')->default(true);

            // امتیاز کاربران
            $table->decimal('rating', 2, 1)->default(0);

            // تعداد بازدید
            $table->integer('views')->default(0);

            $table->timestamps();
        });
    }


    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};