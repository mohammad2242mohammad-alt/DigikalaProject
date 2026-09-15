<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\UpdateSellerOrderItemStatusRequest;
use App\Models\OrderItem;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SellerOrderController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $items = OrderItem::query()
            ->where('seller_id', $request->user()->id)
            ->with([
                'order.user:id,name,email',
                'product:id,name,image',
            ])
            ->latest()
            ->paginate(20);

        return response()->json([
            'success' => true,
            'message' => 'Seller orders retrieved successfully.',
            'data' => $items,
        ]);
    }

    public function show(Request $request, OrderItem $orderItem): JsonResponse
    {
        abort_unless($orderItem->seller_id === $request->user()->id, 404);

        return response()->json([
            'success' => true,
            'message' => 'Seller order retrieved successfully.',
            'data' => $orderItem->load([
                'order.user:id,name,email',
                'product:id,name,image',
            ]),
        ]);
    }

    public function updateStatus(
        UpdateSellerOrderItemStatusRequest $request,
        OrderItem $orderItem,
    ): JsonResponse {
        abort_unless($orderItem->seller_id === $request->user()->id, 404);

        $orderItem->update([
            'fulfillment_status' => $request->validated('status'),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Seller order status updated successfully.',
            'data' => $orderItem->fresh([
                'order.user:id,name,email',
                'product:id,name,image',
            ]),
        ]);
    }
}
