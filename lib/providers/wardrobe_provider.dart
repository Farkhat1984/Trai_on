import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/clothing_item.dart';

final wardrobeProvider = StateNotifierProvider<WardrobeNotifier, List<ClothingItem>>((ref) {
  return WardrobeNotifier();
});

class WardrobeNotifier extends StateNotifier<List<ClothingItem>> {
  WardrobeNotifier() : super([]) {
    _loadWardrobe();
  }

  final _uuid = const Uuid();

  Future<void> _loadWardrobe() async {
    final box = Hive.box('wardrobe');
    final items = <ClothingItem>[];

    for (var key in box.keys) {
      final data = box.get(key) as Map<dynamic, dynamic>;
      items.add(ClothingItem(
        id: data['id'] as String,
        base64Image: data['base64Image'] as String,
        createdAt: DateTime.parse(data['createdAt'] as String),
        description: data['description'] as String?,
      ));
    }

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = items;
  }

  Future<void> addClothingItem(String base64Image, {String? description}) async {
    final item = ClothingItem(
      id: _uuid.v4(),
      base64Image: base64Image,
      createdAt: DateTime.now(),
      description: description,
    );

    final box = Hive.box('wardrobe');
    await box.put(item.id, {
      'id': item.id,
      'base64Image': item.base64Image,
      'createdAt': item.createdAt.toIso8601String(),
      'description': item.description,
    });

    state = [item, ...state];
  }

  Future<void> removeClothingItem(String id) async {
    final box = Hive.box('wardrobe');
    await box.delete(id);
    state = state.where((item) => item.id != id).toList();
  }

  Future<void> updateClothingDescription(String id, String? description) async {
    final box = Hive.box('wardrobe');
    final item = state.firstWhere((item) => item.id == id);

    await box.put(id, {
      'id': item.id,
      'base64Image': item.base64Image,
      'createdAt': item.createdAt.toIso8601String(),
      'description': description,
    });

    state = state.map((item) {
      if (item.id == id) {
        return ClothingItem(
          id: item.id,
          base64Image: item.base64Image,
          createdAt: item.createdAt,
          description: description,
        );
      }
      return item;
    }).toList();
  }

  Future<void> clearWardrobe() async {
    final box = Hive.box('wardrobe');
    await box.clear();
    state = [];
  }
}
