class CategoryModel {
  final int id;
  final int? parentId;
  final String name;
  final String slug;
  final String? image;
  final String? description;
  final List<CategoryModel> children;

  const CategoryModel({
    required this.id,
    this.parentId,
    required this.name,
    required this.slug,
    this.image,
    this.description,
    this.children = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: (json['id'] as num).toInt(),
        parentId: (json['parent_id'] as num?)?.toInt(),
        name: json['name']?.toString() ?? '',
        slug: json['slug']?.toString() ?? '',
        image: json['image']?.toString(),
        description: json['description']?.toString(),
        children: (json['children'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(CategoryModel.fromJson)
            .toList(),
      );
}
