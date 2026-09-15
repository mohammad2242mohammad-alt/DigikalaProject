class Product {
  final int id;
  final int? categoryId;
  final int? sellerId;
  final String? sellerName;
  final String? sellerSlug;
  final String? sellerStatus;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String? image;
  final int stock;
  final bool isActive;
  final double rating;
  final int views;

  Product({
    required this.id,
    this.categoryId,
    this.sellerId,
    this.sellerName,
    this.sellerSlug,
    this.sellerStatus,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    this.image,
    required this.stock,
    required this.isActive,
    required this.rating,
    required this.views,
  });

  double get effectivePrice => discountPrice ?? price;

  factory Product.fromJson(Map<String, dynamic> json) {
    final seller = json['seller'] is Map
        ? Map<String, dynamic>.from(json['seller'] as Map)
        : null;

    return Product(
      id: (json['id'] as num).toInt(),
      categoryId: (json['category_id'] as num?)?.toInt(),
      sellerId: (json['seller_id'] as num?)?.toInt(),
      sellerName: seller?['name']?.toString(),
      sellerSlug: seller?['slug']?.toString(),
      sellerStatus: seller?['status']?.toString(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
      discountPrice: json['discount_price'] == null
          ? null
          : double.tryParse(json['discount_price'].toString()),
      image: json['image']?.toString(),
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0,
      views: (json['views'] as num?)?.toInt() ?? 0,
    );
  }
}
