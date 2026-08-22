class HomeBanner {
  const HomeBanner({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.description,
    this.link,
    this.sortOrder = 0,
  });

  final String id;
  final String title;
  final String imageUrl;
  final String? description;
  final String? link;
  final int sortOrder;

  factory HomeBanner.fromJson(Map<String, dynamic> json) {
    return HomeBanner(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ??
          json['imageUrl']?.toString() ??
          '',
      description: json['description']?.toString(),
      link: json['link']?.toString(),
      sortOrder: (json['sort_order'] as num?)?.toInt() ??
          (json['sortOrder'] as num?)?.toInt() ??
          0,
    );
  }

  bool get hasImage => imageUrl.trim().isNotEmpty;
}
