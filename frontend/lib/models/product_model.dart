class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final double discountPrice;
  final String? image;
  final int stock;
  final bool isActive;
  final double rating;
  final int views;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.discountPrice,
    this.image,
    required this.stock,
    required this.isActive,
    required this.rating,
    required this.views,
  });

  double get effectivePrice =>
      discountPrice > 0 && discountPrice < price ? discountPrice : price;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
      discountPrice: double.tryParse(json['discount_price']?.toString() ?? '') ?? 0,
      image: json['image']?.toString(),
      stock: int.tryParse(json['stock']?.toString() ?? '') ?? 0,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0,
      views: int.tryParse(json['views']?.toString() ?? '') ?? 0,
    );
  }
}
