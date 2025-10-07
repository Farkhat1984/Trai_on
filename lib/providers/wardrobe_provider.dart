import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/clothing_item.dart';
import '../constants/app_constants.dart';

final wardrobeProvider =
    StateNotifierProvider<WardrobeNotifier, List<ClothingItem>>((ref) {
  return WardrobeNotifier();
});

// Селекторы для оптимизации
final wardrobeCountProvider = Provider<int>((ref) {
  return ref.watch(wardrobeProvider.select((items) => items.length));
});

final wardrobeEmptyProvider = Provider<bool>((ref) {
  return ref.watch(wardrobeProvider.select((items) => items.isEmpty));
});

class WardrobeNotifier extends StateNotifier<List<ClothingItem>> {
  WardrobeNotifier() : super([]) {
    _loadWardrobe();
  }

  final _uuid = const Uuid();

  Future<void> _loadWardrobe() async {
    final box = Hive.box(AppConstants.hiveBoxWardrobe);
    final items = <ClothingItem>[];

    for (var key in box.keys) {
      try {
        final data = box.get(key) as Map<dynamic, dynamic>;
        items.add(ClothingItem(
          id: data['id'] as String,
          base64Image: data['base64Image'] as String,
          createdAt: DateTime.parse(data['createdAt'] as String),
          description: data['description'] as String?,
        ));
      } catch (error) {
        // Пропускаем поврежденные элементы
        continue;
      }
    }

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = items;
  }

  Future<void> addClothingItem(String base64Image,
      {String? description}) async {
    final item = ClothingItem(
      id: _uuid.v4(),
      base64Image: base64Image,
      createdAt: DateTime.now(),
      description: description,
    );

    final box = Hive.box(AppConstants.hiveBoxWardrobe);
    await box.put(item.id, {
      'id': item.id,
      'base64Image': item.base64Image,
      'createdAt': item.createdAt.toIso8601String(),
      'description': item.description,
    });

    // Оптимизация: создаем новый список вместо изменения текущего
    state = [item, ...state];
  }

  Future<void> removeClothingItem(String id) async {
    final box = Hive.box(AppConstants.hiveBoxWardrobe);
    await box.delete(id);
    // Оптимизация: используем where вместо создания нового списка вручную
    state = state.where((item) => item.id != id).toList();
  }

  Future<void> updateClothingDescription(String id, String? description) async {
    final index = state.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final item = state[index];
    final box = Hive.box(AppConstants.hiveBoxWardrobe);

    await box.put(id, {
      'id': item.id,
      'base64Image': item.base64Image,
      'createdAt': item.createdAt.toIso8601String(),
      'description': description,
    });

    // Оптимизация: обновляем только конкретный элемент
    final updatedItem = ClothingItem(
      id: item.id,
      base64Image: item.base64Image,
      createdAt: item.createdAt,
      description: description,
    );

    final newState = List<ClothingItem>.from(state);
    newState[index] = updatedItem;
    state = newState;
  }

  Future<void> clearWardrobe() async {
    final box = Hive.box(AppConstants.hiveBoxWardrobe);
    await box.clear();
    state = [];
  }
}
