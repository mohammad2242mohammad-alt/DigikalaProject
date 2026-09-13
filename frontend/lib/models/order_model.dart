class OrderItemModel {
  final int id;
  final int? productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double totalPrice;

  const OrderItemModel({
    required this.id,
    this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        id: (json['id'] as num).toInt(),
        productId: (json['product_id'] as num?)?.toInt(),
        productName: json['product_name']?.toString() ?? '',
        unitPrice: double.tryParse(json['unit_price']?.toString() ?? '') ?? 0,
        quantity: (json['quantity'] as num?)?.toInt() ?? 0,
        totalPrice: double.tryParse(json['total_price']?.toString() ?? '') ?? 0,
      );
}

class PaymentModel {
  final int id;
  final String method;
  final String status;
  final String? transactionId;
  final double amount;

  const PaymentModel({
    required this.id,
    required this.method,
    required this.status,
    this.transactionId,
    required this.amount,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
        id: (json['id'] as num).toInt(),
        method: json['method']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        transactionId: json['transaction_id']?.toString(),
        amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0,
      );
}

class OrderModel {
  final int id;
  final String recipientName;
  final String phone;
  final String province;
  final String city;
  final String address;
  final String postalCode;
  final double subtotal;
  final double shippingPrice;
  final double discountAmount;
  final double total;
  final String status;
  final List<OrderItemModel> items;
  final List<PaymentModel> payments;

  const OrderModel({
    required this.id,
    required this.recipientName,
    required this.phone,
    required this.province,
    required this.city,
    required this.address,
    required this.postalCode,
    required this.subtotal,
    required this.shippingPrice,
    required this.discountAmount,
    required this.total,
    required this.status,
    required this.items,
    required this.payments,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: (json['id'] as num).toInt(),
        recipientName: json['recipient_name']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        province: json['province']?.toString() ?? '',
        city: json['city']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        postalCode: json['postal_code']?.toString() ?? '',
        subtotal: double.tryParse(json['subtotal']?.toString() ?? '') ?? 0,
        shippingPrice: double.tryParse(json['shipping_price']?.toString() ?? '') ?? 0,
        discountAmount: double.tryParse(json['discount_amount']?.toString() ?? '') ?? 0,
        total: double.tryParse(json['total']?.toString() ?? '') ?? 0,
        status: json['status']?.toString() ?? '',
        items: (json['items'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(OrderItemModel.fromJson)
            .toList(),
        payments: (json['payments'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(PaymentModel.fromJson)
            .toList(),
      );
}
