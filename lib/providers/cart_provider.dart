import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../models/shop_item.dart';
import '../utils/logger.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  // Добавить товар в корзину
  void addItem(ShopItem shopItem, {int quantity = 1}) {
    final existingIndex =
        state.indexWhere((item) => item.shopItem.id == shopItem.id);

    if (existingIndex >= 0) {
      // Товар уже есть в корзине - увеличиваем количество
      final updatedItem = state[existingIndex]
          .copyWith(quantity: state[existingIndex].quantity + quantity);
      state = [
        ...state.sublist(0, existingIndex),
        updatedItem,
        ...state.sublist(existingIndex + 1),
      ];
      logger.d('Увеличено количество товара ${shopItem.name} в корзине');
    } else {
      // Добавляем новый товар
      state = [...state, CartItem(shopItem: shopItem, quantity: quantity)];
      logger.d('Товар ${shopItem.name} добавлен в корзину');
    }
  }

  // Удалить товар из корзины
  void removeItem(String shopItemId) {
    state = state.where((item) => item.shopItem.id != shopItemId).toList();
    logger.d('Товар удален из корзины');
  }

  // Увеличить количество товара
  void incrementQuantity(String shopItemId) {
    final index = state.indexWhere((item) => item.shopItem.id == shopItemId);
    if (index >= 0) {
      final updatedItem =
          state[index].copyWith(quantity: state[index].quantity + 1);
      state = [
        ...state.sublist(0, index),
        updatedItem,
        ...state.sublist(index + 1),
      ];
    }
  }

  // Уменьшить количество товара
  void decrementQuantity(String shopItemId) {
    final index = state.indexWhere((item) => item.shopItem.id == shopItemId);
    if (index >= 0) {
      if (state[index].quantity > 1) {
        final updatedItem =
            state[index].copyWith(quantity: state[index].quantity - 1);
        state = [
          ...state.sublist(0, index),
          updatedItem,
          ...state.sublist(index + 1),
        ];
      } else {
        // Если количество = 1, удаляем товар
        removeItem(shopItemId);
      }
    }
  }

  // Установить количество товара
  void setQuantity(String shopItemId, int quantity) {
    if (quantity <= 0) {
      removeItem(shopItemId);
      return;
    }

    final index = state.indexWhere((item) => item.shopItem.id == shopItemId);
    if (index >= 0) {
      final updatedItem = state[index].copyWith(quantity: quantity);
      state = [
        ...state.sublist(0, index),
        updatedItem,
        ...state.sublist(index + 1),
      ];
    }
  }

  // Очистить корзину
  void clear() {
    state = [];
    logger.d('Корзина очищена');
  }

  // Получить общее количество товаров
  int get totalItems {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }

  // Получить общую сумму
  double get totalPrice {
    return state.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Проверить, есть ли товар в корзине
  bool containsItem(String shopItemId) {
    return state.any((item) => item.shopItem.id == shopItemId);
  }

  // Получить количество конкретного товара
  int getItemQuantity(String shopItemId) {
    final item = state.firstWhere(
      (item) => item.shopItem.id == shopItemId,
      orElse: () => CartItem(
        shopItem: ShopItem(
          id: '',
          name: '',
          price: 0,
          description: '',
          base64Image: '',
          category: '',
        ),
        quantity: 0,
      ),
    );
    return item.quantity;
  }
}

// Provider для корзины
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

// Provider для общего количества товаров в корзине
final cartTotalItemsProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});

// Provider для общей суммы корзины
final cartTotalPriceProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, item) => sum + item.totalPrice);
});
