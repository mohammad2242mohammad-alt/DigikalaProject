class AddressModel {
  final int id;
  final String? title;
  final String recipientName;
  final String phone;
  final String province;
  final String city;
  final String address;
  final String postalCode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  const AddressModel({
    required this.id,
    this.title,
    required this.recipientName,
    required this.phone,
    required this.province,
    required this.city,
    required this.address,
    required this.postalCode,
    this.latitude,
    this.longitude,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        id: (json['id'] as num).toInt(),
        title: json['title']?.toString(),
        recipientName: json['recipient_name']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        province: json['province']?.toString() ?? '',
        city: json['city']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        postalCode: json['postal_code']?.toString() ?? '',
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        isDefault: json['is_default'] == true || json['is_default'] == 1,
      );
}
