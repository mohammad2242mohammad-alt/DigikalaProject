class CategoryModel {
  final int id;
  final String name;
  final int? parentId;
  final List<CategoryModel> children;

  const CategoryModel({
    required this.id,
    required this.name,
    this.parentId,
    this.children = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'];
    return CategoryModel(
      id: int.parse(json['id'].toString()),
      name: json['name']?.toString() ?? '',
      parentId: json['parent_id'] == null ? null : int.parse(json['parent_id'].toString()),
      children: rawChildren is List
          ? rawChildren.map((item) => CategoryModel.fromJson(Map<String, dynamic>.from(item as Map))).toList()
          : const [],
    );
  }
}
