import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/shop_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/cart_expanded_provider.dart';
import '../providers/wardrobe_provider.dart';
import '../services/image_service.dart';
import '../services/sound_service.dart';
import '../services/flying_widget_service.dart';
import '../widgets/shop_item_card.dart';
import '../widgets/cart_widget.dart';
import '../widgets/product_detail_dialog.dart';
import '../utils/logger.dart';
import '../main.dart' show homeIconKey;

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final _searchController = TextEditingController();
  final _imageService = ImageService();
  final GlobalKey _cartIconKey = GlobalKey();
  final Map<String, GlobalKey> _itemKeys = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(shopProvider.notifier).setSearchQuery(query);
  }

  Future<void> _showImageSourceDialog() async {
    // Показываем диалог выбора источника изображения
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить изображение'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Выбрать из галереи'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Сделать фото'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
          ],
        ),
      ),
    );

    if (result == 'gallery') {
      _pickImageFromGallery();
    } else if (result == 'camera') {
      _pickImageFromCamera();
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final base64 = await _imageService.pickImageFromGallery();
      if (base64 != null && mounted) {
        // TODO: Здесь будет семантический поиск по изображению
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Поиск по фото находится в разработке.\nВ будущем это позволит найти похожие товары.',
            ),
            duration: Duration(seconds: 3),
          ),
        );
        logger.d('Получено изображение из галереи для семантического поиска');
      }
    } catch (e) {
      logger.e('Ошибка при выборе изображения из галереи: $e');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final base64 =
          await _imageService.pickImageFromCamera(preferFrontCamera: false);
      if (base64 != null && mounted) {
        // TODO: Здесь будет семантический поиск по изображению
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Поиск по фото находится в разработке.\nВ будущем это позволит найти похожие товары.',
            ),
            duration: Duration(seconds: 3),
          ),
        );
        logger.d('Получено изображение с камеры для семантического поиска');
      }
    } catch (e) {
      logger.e('Ошибка при съемке фото: $e');
    }
  }

  void _onItemSingleTap(String itemId) {
    // 1 клик - добавить в корзину с анимацией полета
    final item = ref.read(shopProvider.notifier).getItemById(itemId);
    if (item == null) return;

    // Проигрываем звук
    SoundService().playFlying(duration: const Duration(milliseconds: 600));

    // Получаем ключи для анимации
    final itemKey = _itemKeys[itemId];
    if (itemKey == null ||
        itemKey.currentContext == null ||
        _cartIconKey.currentContext == null) {
      // Если анимация не может быть запущена, просто добавляем в корзину
      ref.read(cartProvider.notifier).addItem(item);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} добавлен в корзину'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Запускаем анимацию полета в корзину
    FlyingWidgetService.flyWidget(
      context: context,
      sourceKey: itemKey,
      targetKey: _cartIconKey,
      imageBase64: item.base64Image,
      targetOffset: const Offset(0, -2),
      duration: const Duration(milliseconds: 600),
      onComplete: () {
        // Добавляем товар в корзину после завершения анимации
        ref.read(cartProvider.notifier).addItem(item);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} добавлен в корзину'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  void _onItemDoubleTap(String itemId) async {
    // 2 клика - добавить в гардероб с анимацией
    final item = ref.read(shopProvider.notifier).getItemById(itemId);
    if (item == null) return;

    // Проигрываем звук
    SoundService().playFlying(duration: const Duration(milliseconds: 800));

    // Получаем ключи для анимации
    final itemKey = _itemKeys[itemId];
    if (itemKey == null || itemKey.currentContext == null) {
      // Если анимация не может быть запущена, просто добавляем в гардероб
      final base64Image = await _convertToBase64(item.base64Image);
      if (base64Image != null) {
        ref.read(wardrobeProvider.notifier).addClothingItem(base64Image);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item.name} добавлен в гардероб'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
      return;
    }

    // Запускаем анимацию полета в гардероб (на главную)
    FlyingWidgetService.flyWidget(
      context: context,
      sourceKey: itemKey,
      targetKey: homeIconKey,
      imageBase64: item.base64Image,
      targetOffset: const Offset(0, -4),
      duration: const Duration(milliseconds: 800),
      onComplete: () async {
        // Конвертируем в base64 перед добавлением в гардероб
        final base64Image = await _convertToBase64(item.base64Image);
        if (base64Image != null) {
          ref.read(wardrobeProvider.notifier).addClothingItem(base64Image);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${item.name} добавлен в гардероб'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
    );
  }

  /// Конвертирует asset путь или base64 строку в base64
  Future<String?> _convertToBase64(String imageStr) async {
    if (imageStr.startsWith('assets/')) {
      // Это asset путь, нужно загрузить и конвертировать
      try {
        final byteData = await rootBundle.load(imageStr);
        final bytes = byteData.buffer.asUint8List();
        return base64Encode(bytes);
      } catch (e) {
        logger.e('Ошибка при конвертации asset в base64: $e');
        return null;
      }
    } else {
      // Уже base64 строка
      return imageStr;
    }
  }

  void _onItemLongPress(String itemId) {
    // Долгое нажатие - показать детали товара
    final item = ref.read(shopProvider.notifier).getItemById(itemId);
    if (item != null) {
      showDialog(
        context: context,
        builder: (context) => ProductDetailDialog(item: item),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final shopItems = ref.watch(shopProvider);
    final categories = ref.watch(shopCategoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final isCartExpanded = ref.watch(cartExpandedProvider);

    return Scaffold(
      body: Column(
        children: [
          // Хедер с поиском и категориями
          Container(
            padding: EdgeInsets.fromLTRB(
                16, MediaQuery.of(context).padding.top + 16, 16, 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Строка поиска и корзина на одной линии
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Поиск товаров...',
                          prefixIcon: IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            tooltip: 'Добавить фото для поиска',
                            onPressed: _showImageSourceDialog,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                    setState(() {});
                                  },
                                )
                              : const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.background,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {});
                          _onSearchChanged(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Иконка корзины
                    GestureDetector(
                      key: _cartIconKey,
                      onTap: () {
                        // Переключаем состояние корзины
                        ref.read(cartExpandedProvider.notifier).state =
                            !ref.read(cartExpandedProvider);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(
                              Icons.shopping_cart,
                              color: Colors.white,
                              size: 28,
                            ),
                            Consumer(
                              builder: (context, ref, _) {
                                final totalItems =
                                    ref.watch(cartTotalItemsProvider);
                                if (totalItems > 0) {
                                  return Positioned(
                                    right: -8,
                                    top: -8,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                      ),
                                      child: Text(
                                        totalItems > 99
                                            ? '99+'
                                            : totalItems.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Фильтр по категориям
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = category == selectedCategory;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            ref.read(selectedCategoryProvider.notifier).state =
                                category;
                            ref
                                .read(shopProvider.notifier)
                                .setCategory(category);
                          },
                          selectedColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.2),
                          checkmarkColor: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Корзина (если открыта)
          if (isCartExpanded)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: CartWidget(cartIconKey: _cartIconKey),
            ).animate().slideY(begin: -0.2, end: 0, duration: 300.ms).fadeIn(),

          // Сетка товаров
          Expanded(
            child: shopItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Товары не найдены',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Попробуйте изменить критерии поиска',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: shopItems.length,
                    itemBuilder: (context, index) {
                      final item = shopItems[index];

                      // Создаем уникальный ключ для каждого товара
                      _itemKeys[item.id] ??= GlobalKey();

                      return ShopItemCard(
                        item: item,
                        cardKey: _itemKeys[item.id],
                        onTap: () => _onItemSingleTap(item.id),
                        onDoubleTap: () => _onItemDoubleTap(item.id),
                        onLongPress: () => _onItemLongPress(item.id),
                      ).animate().fadeIn(delay: (index * 50).ms).slideY(
                            begin: 0.2,
                            end: 0,
                            duration: 300.ms,
                          );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
