<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->foreignId('seller_id')->nullable()->after('category_id')->constrained('users')->nullOnDelete();
            $table->enum('approval_status', ['pending', 'approved', 'rejected'])->default('approved')->after('is_active');
            $table->text('rejection_reason')->nullable()->after('approval_status');
            $table->index(['seller_id', 'approval_status']);
        });
    }

    public function down(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->dropForeign(['seller_id']);
            $table->dropIndex(['seller_id', 'approval_status']);
            $table->dropColumn(['seller_id', 'approval_status', 'rejection_reason']);
        });
    }
};
