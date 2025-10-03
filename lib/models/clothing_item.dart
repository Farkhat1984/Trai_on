import 'package:hive/hive.dart';

part 'clothing_item.g.dart';

@HiveType(typeId: 0)
class ClothingItem {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String base64Image;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final String? description;

  ClothingItem({
    required this.id,
    required this.base64Image,
    required this.createdAt,
    this.description,
  });

  ClothingItem copyWith({
    String? id,
    String? base64Image,
    DateTime? createdAt,
    String? description,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      base64Image: base64Image ?? this.base64Image,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
    );
  }
}
