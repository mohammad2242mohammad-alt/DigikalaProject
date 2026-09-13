<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\CheckoutRequest;
use App\Http\Requests\UpdateOrderStatusRequest;
use App\Models\Order;
use App\Services\OrderService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $orders = Order::query()
            ->where('user_id', $request->user()->id)
            ->with(['items', 'payments'])
            ->latest()
            ->paginate(20);

        return response()->json([
            'success' => true,
            'message' => 'Orders retrieved successfully.',
            'data' => $orders,
        ]);
    }

    public function show(Request $request, Order $order): JsonResponse
    {
        abort_unless($order->user_id === $request->user()->id, 404);

        return response()->json([
            'success' => true,
            'message' => 'Order retrieved successfully.',
            'data' => $order->load(['items', 'payments']),
        ]);
    }

    public function checkout(CheckoutRequest $request, OrderService $orderService): JsonResponse
    {
        $order = $orderService->checkout(
            $request->user()->id,
            (int) $request->validated('address_id'),
        );

        return response()->json([
            'success' => true,
            'message' => 'Order created successfully.',
            'data' => $order,
        ], 201);
    }

    public function adminIndex(): JsonResponse
    {
        $orders = Order::query()
            ->with(['user:id,name,email', 'items', 'payments'])
            ->latest()
            ->paginate(30);

        return response()->json([
            'success' => true,
            'message' => 'Admin orders retrieved successfully.',
            'data' => $orders,
        ]);
    }

    public function adminUpdateStatus(UpdateOrderStatusRequest $request, Order $order): JsonResponse
    {
        $order->update(['status' => $request->validated('status')]);

        return response()->json([
            'success' => true,
            'message' => 'Order status updated successfully.',
            'data' => $order->fresh(['user:id,name,email', 'items', 'payments']),
        ]);
    }
}
