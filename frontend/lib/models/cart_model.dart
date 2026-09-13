import 'product_model.dart';

class CartItemModel {
  final int id;
  final int quantity;
  final Product product;
  final double unitPrice;

  const CartItemModel({
    required this.id,
    required this.quantity,
    required this.product,
    required this.unitPrice,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
        id: (json['id'] as num).toInt(),
        quantity: (json['quantity'] as num).toInt(),
        product: Product.fromJson(json['product'] as Map<String, dynamic>),
        unitPrice: double.tryParse(json['unit_price']?.toString() ?? '') ?? 0,
      );
}

class CartModel {
  final int? id;
  final int itemsCount;
  final double subtotal;
  final double totalPrice;
  final List<CartItemModel> items;

  const CartModel({
    this.id,
    required this.itemsCount,
    required this.subtotal,
    required this.totalPrice,
    required this.items,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(
        id: (json['id'] as num?)?.toInt(),
        itemsCount: (json['items_count'] as num?)?.toInt() ?? 0,
        subtotal: double.tryParse(json['subtotal']?.toString() ?? '') ?? 0,
        totalPrice: double.tryParse(json['total_price']?.toString() ?? '') ?? 0,
        items: (json['items'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(CartItemModel.fromJson)
            .toList(),
      );
}
