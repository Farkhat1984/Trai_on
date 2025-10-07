import 'shop_item.dart';

class CartItem {
  final ShopItem shopItem;
  final int quantity;

  const CartItem({
    required this.shopItem,
    required this.quantity,
  });

  double get totalPrice => shopItem.price * quantity;

  CartItem copyWith({
    ShopItem? shopItem,
    int? quantity,
  }) {
    return CartItem(
      shopItem: shopItem ?? this.shopItem,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          shopItem.id == other.shopItem.id;

  @override
  int get hashCode => shopItem.id.hashCode;
}
