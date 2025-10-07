class ShopItem {
  final String id;
  final String name;
  final double price;
  final String description;
  final String base64Image;
  final List<String> additionalImages;
  final String category;
  final String? brand;
  final List<String>? sizes;
  final List<String>? colors;
  final double? rating;
  final int? reviewsCount;

  const ShopItem({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.base64Image,
    this.additionalImages = const [],
    required this.category,
    this.brand,
    this.sizes,
    this.colors,
    this.rating,
    this.reviewsCount,
  });

  ShopItem copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    String? base64Image,
    List<String>? additionalImages,
    String? category,
    String? brand,
    List<String>? sizes,
    List<String>? colors,
    double? rating,
    int? reviewsCount,
  }) {
    return ShopItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      base64Image: base64Image ?? this.base64Image,
      additionalImages: additionalImages ?? this.additionalImages,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
