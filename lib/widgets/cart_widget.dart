import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../providers/cart_expanded_provider.dart';
import '../screens/checkout_screen.dart';

// Helper function to build image from asset or base64
Widget _buildCartImage(String imageStr,
    {required double width, required double height}) {
  if (imageStr.startsWith('assets/')) {
    return Image.asset(
      imageStr,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.broken_image, size: 24, color: Colors.grey),
          ),
        );
      },
    );
  } else {
    try {
      return Image.memory(
        base64Decode(imageStr),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.broken_image, size: 24, color: Colors.grey),
            ),
          );
        },
      );
    } catch (e) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.broken_image, size: 24, color: Colors.grey),
        ),
      );
    }
  }
}

class CartWidget extends ConsumerStatefulWidget {
  final GlobalKey cartIconKey;

  const CartWidget({
    super.key,
    required this.cartIconKey,
  });

  @override
  ConsumerState<CartWidget> createState() => _CartWidgetState();
}

class _CartWidgetState extends ConsumerState<CartWidget> {
  @override
  void didUpdateWidget(CartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Автоматически сворачиваем корзину когда она пуста
    final cartItems = ref.read(cartProvider);
    final isExpanded = ref.read(cartExpandedProvider);
    if (cartItems.isEmpty && isExpanded) {
      ref.read(cartExpandedProvider.notifier).state = false;
    }
  }

  void _navigateToCheckout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CheckoutScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final totalPrice = ref.watch(cartTotalPriceProvider);
    final isExpanded = ref.watch(cartExpandedProvider);

    // Если корзина не раскрыта, ничего не показываем
    if (!isExpanded) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 500),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Заголовок
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_cart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Корзина',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                if (cartItems.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete_sweep),
                    tooltip: 'Очистить корзину',
                    onPressed: () {
                      _showClearCartDialog();
                    },
                  ),
              ],
            ),
          ),

          // Список товаров
          Expanded(
            child: cartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Корзина пуста',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Добавьте товары для покупки',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: cartItems.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final cartItem = cartItems[index];
                      return _CartItemTile(cartItem: cartItem);
                    },
                  ),
          ),

          // Итоговая сумма и кнопка оформления
          if (cartItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surface
                    .withValues(alpha: 0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Итого:',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      Text(
                        '${totalPrice.toStringAsFixed(0)} ₽',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _navigateToCheckout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Купить',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить корзину?'),
        content: const Text('Все товары будут удалены из корзины.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              ref.read(cartProvider.notifier).clear();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Очистить'),
          ),
        ],
      ),
    );
  }
}

// Виджет элемента корзины
class _CartItemTile extends ConsumerWidget {
  final CartItem cartItem;

  const _CartItemTile({required this.cartItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Изображение товара
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildCartImage(
              cartItem.shopItem.base64Image,
              width: 60,
              height: 60,
            ),
          ),
          const SizedBox(width: 12),

          // Информация о товаре
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.shopItem.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${cartItem.shopItem.price.toStringAsFixed(0)} ₽',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Кнопка уменьшения
                    IconButton(
                      onPressed: () {
                        ref
                            .read(cartProvider.notifier)
                            .decrementQuantity(cartItem.shopItem.id);
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                      iconSize: 20,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),

                    // Количество
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${cartItem.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Кнопка увеличения
                    IconButton(
                      onPressed: () {
                        ref
                            .read(cartProvider.notifier)
                            .incrementQuantity(cartItem.shopItem.id);
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      iconSize: 20,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      color: Theme.of(context).colorScheme.primary,
                    ),

                    const Spacer(),

                    // Общая стоимость
                    Text(
                      '${cartItem.totalPrice.toStringAsFixed(0)} ₽',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Кнопка удаления
          IconButton(
            onPressed: () {
              ref.read(cartProvider.notifier).removeItem(cartItem.shopItem.id);
            },
            icon: const Icon(Icons.close),
            iconSize: 20,
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }
}
