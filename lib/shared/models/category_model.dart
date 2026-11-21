class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final int count;
  final String imageUrl;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.count,
    required this.imageUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    String img = '';
    if (json['image'] is Map && json['image']['src'] != null) {
      img = json['image']['src'].toString();
    }
    if (img.isEmpty) {
      img = 'https://images.unsplash.com/photo-1490578474895-699cd4e2cf59?w=600';
    }

    return CategoryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      count: json['count'] is int ? json['count'] : int.tryParse(json['count']?.toString() ?? '0') ?? 0,
      imageUrl: img,
    );
  }
}
