<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class PaymentController extends Controller
{
    public function pay(Request $request, Order $order): JsonResponse
    {
        abort_unless($order->user_id === $request->user()->id, 404);

        $payment = $order->payments()->latest()->first();

        if (! $payment) {
            throw ValidationException::withMessages([
                'payment' => ['پرداختی برای این سفارش وجود ندارد.'],
            ]);
        }

        $wasAlreadyPaid = $payment->status === 'paid';

        $payment = DB::transaction(function () use ($payment, $order) {
            $lockedPayment = $order->payments()
                ->whereKey($payment->id)
                ->lockForUpdate()
                ->firstOrFail();

            if ($lockedPayment->status === 'paid') {
                return $lockedPayment;
            }

            $order->load('items');

            foreach ($order->items as $item) {
                $updated = DB::table('products')
                    ->where('id', $item->product_id)
                    ->where('is_active', true)
                    ->where('stock', '>=', $item->quantity)
                    ->decrement('stock', $item->quantity);

                if ($updated !== 1) {
                    throw ValidationException::withMessages([
                        'payment' => ["موجودی محصول «{$item->product_name}» برای پرداخت کافی نیست."],
                    ]);
                }
            }

            $lockedPayment->update([
                'status' => 'paid',
                'transaction_id' => 'MOCK-' . Str::upper(Str::random(16)),
                'paid_at' => now(),
            ]);

            $order->update(['status' => 'paid']);

            return $lockedPayment->fresh();
        });

        return response()->json([
            'success' => true,
            'message' => $wasAlreadyPaid
                ? 'Order is already paid.'
                : 'Mock payment completed successfully.',
            'data' => $payment,
        ]);
    }
}
