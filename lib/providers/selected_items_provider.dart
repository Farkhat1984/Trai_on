import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/clothing_item.dart';

final selectedItemsProvider = StateNotifierProvider<SelectedItemsNotifier, List<ClothingItem>>((ref) {
  return SelectedItemsNotifier();
});

class SelectedItemsNotifier extends StateNotifier<List<ClothingItem>> {
  SelectedItemsNotifier() : super([]);

  void addItem(ClothingItem item) {
    if (!state.any((i) => i.id == item.id)) {
      state = [...state, item];
    }
  }

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void clear() {
    state = [];
  }
}
