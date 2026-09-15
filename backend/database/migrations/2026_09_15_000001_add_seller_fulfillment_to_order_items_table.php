<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('order_items', function (Blueprint $table) {
            $table->foreignId('seller_id')->nullable()->after('product_id')->constrained('users')->nullOnDelete();
            $table->string('fulfillment_status')->default('pending')->after('total_price');
            $table->index(['seller_id', 'fulfillment_status']);
        });
    }

    public function down(): void
    {
        Schema::table('order_items', function (Blueprint $table) {
            $table->dropForeign(['seller_id']);
            $table->dropIndex(['seller_id', 'fulfillment_status']);
            $table->dropColumn(['seller_id', 'fulfillment_status']);
        });
    }
};
