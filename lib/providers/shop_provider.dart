import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shop_item.dart';
import '../utils/logger.dart';
import '../data/mock_shop_items.dart';

class ShopNotifier extends StateNotifier<List<ShopItem>> {
  ShopNotifier() : super([]) {
    _loadMockData();
  }

  String _searchQuery = '';
  String _selectedCategory = 'Все';

  // Загрузка моковых данных
  Future<void> _loadMockData() async {
    state = _getMockItems();
    logger.d('Загружено ${state.length} товаров');
  }

  // Получить моковые товары
  List<ShopItem> _getMockItems() {
    return getMockShopItems();
  }

  // Установить поисковый запрос
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _filterItems();
  }

  // Установить категорию
  void setCategory(String category) {
    _selectedCategory = category;
    _filterItems();
  }

  // Фильтрация товаров
  void _filterItems() {
    final allItems = _getMockItems();

    List<ShopItem> filtered = allItems;

    // Фильтр по категории
    if (_selectedCategory != 'Все') {
      filtered =
          filtered.where((item) => item.category == _selectedCategory).toList();
    }

    // Фильтр по поиску
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.name.toLowerCase().contains(_searchQuery) ||
            item.description.toLowerCase().contains(_searchQuery) ||
            (item.brand?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }

    state = filtered;
    logger.d('Отфильтровано ${state.length} товаров');
  }

  // Получить все доступные категории
  List<String> getCategories() {
    final categories =
        _getMockItems().map((item) => item.category).toSet().toList();
    return ['Все', ...categories];
  }

  // Сбросить фильтры
  void resetFilters() {
    _searchQuery = '';
    _selectedCategory = 'Все';
    state = _getMockItems();
  }

  // Получить товар по ID
  ShopItem? getItemById(String id) {
    try {
      return _getMockItems().firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }
}

// Provider для магазина
final shopProvider = StateNotifierProvider<ShopNotifier, List<ShopItem>>((ref) {
  return ShopNotifier();
});

// Provider для категорий
final shopCategoriesProvider = Provider<List<String>>((ref) {
  return ref.watch(shopProvider.notifier).getCategories();
});

// Provider для текущей категории
final selectedCategoryProvider = StateProvider<String>((ref) => 'Все');

// Provider для поискового запроса
final searchQueryProvider = StateProvider<String>((ref) => '');
