import 'product_model.dart';

class SellerStore {
  const SellerStore({
    required this.id,
    required this.userId,
    required this.storeName,
    required this.slug,
    required this.description,
    this.logo,
    required this.status,
  });

  final int id;
  final int userId;
  final String storeName;
  final String slug;
  final String description;
  final String? logo;
  final String status;

  factory SellerStore.fromJson(Map<String, dynamic> json) {
    return SellerStore(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      storeName: json['store_name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      logo: json['logo']?.toString(),
      status: json['status']?.toString() ?? '',
    );
  }
}

class SellerStoreData {
  const SellerStoreData({required this.seller, required this.products});

  final SellerStore seller;
  final List<Product> products;
}
