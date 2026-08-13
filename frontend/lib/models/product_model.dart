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


  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: double.parse(json['price'].toString()),
      discountPrice:
          double.parse(json['discount_price'].toString()),
      image: json['image'],
      stock: json['stock'],
      isActive: json['is_active'] == 1,
      rating: double.parse(json['rating'].toString()),
      views: json['views'],
    );
  }
}