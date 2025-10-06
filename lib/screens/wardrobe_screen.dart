import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/wardrobe_provider.dart';
import '../services/flying_widget_service.dart';
import '../main.dart' show cartIconKey;
import '../providers/selected_items_provider.dart';
import '../providers/fab_state_provider.dart';
import '../services/image_service.dart';
import '../services/api_service.dart';
import '../models/clothing_item.dart';
import '../widgets/clothing_card_widget.dart';
import 'dart:convert' show base64Decode;

class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key});

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen> {
  final _imageService = ImageService();
  final _apiService = ApiService();
  final _clothingPromptController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _clothingPromptController.dispose();
    super.dispose();
  }

  Future<void> _pickClothingImages() async {
    ref.read(fabStateProvider.notifier).state = false;
    try {
      final base64List = await _imageService.pickMultipleImagesFromGallery();
      for (final base64 in base64List) {
        await ref.read(wardrobeProvider.notifier).addClothingItem(base64);
      }
    } catch (e) {
      _showError('Ошибка при загрузке одежды: $e');
    }
  }

  // Сразу запускаем заднюю камеру без выбора
  Future<void> _takeClothingPhoto() async {
    ref.read(fabStateProvider.notifier).state = false;
    try {
      // Всегда используем заднюю камеру (preferFrontCamera: false)
      final base64 =
          await _imageService.pickImageFromCamera(preferFrontCamera: false);
      if (base64 != null) {
        await ref.read(wardrobeProvider.notifier).addClothingItem(base64);
      }
    } catch (e) {
      _showError('Ошибка при съемке фото одежды: $e');
    }
  }

  void _showCameraOptions() {
    ref.read(fabStateProvider.notifier).state = false;
    _takeClothingPhoto();
  }

  Future<void> _generateClothing() async {
    final description = _clothingPromptController.text.trim();
    if (description.isEmpty) {
      _showError('Введите описание одежды');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final base64 = await _apiService.generateClothingImage(description);
      await ref
          .read(wardrobeProvider.notifier)
          .addClothingItem(base64, description: description);
      _clothingPromptController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Одежда создана!'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      _showError('Ошибка генерации одежды: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showGenerateDialog() {
    ref.read(fabStateProvider.notifier).state = false;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Создать одежду с ИИ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _clothingPromptController,
              decoration: const InputDecoration(
                hintText: 'Опишите одежду...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _generateClothing();
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _onItemDoubleTap(ClothingItem item, GlobalKey itemKey) {
    // Запускаем flying animation
    FlyingWidgetService.flyWidget(
      context: context,
      sourceKey: itemKey,
      targetKey: cartIconKey,
      targetOffset: const Offset(0, 24),
      imageBase64: item.base64Image,
      duration: const Duration(milliseconds: 800),
      onComplete: () {
        // После анимации добавляем в корзину
        ref.read(selectedItemsProvider.notifier).addItem(item);

        // Показываем уведомление
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('${item.description ?? "Одежда"} добавлена в корзину'),
              duration: const Duration(milliseconds: 800),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    );
  }

  void _deleteClothingItem(ClothingItem item) {
    ref.read(wardrobeProvider.notifier).removeClothingItem(item.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Удалено из гардероба'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _saveClothingToGallery(ClothingItem item) async {
    try {
      final bytes = base64Decode(item.base64Image);
      final result = await _imageService.saveImageToGallery(bytes);

      if (result && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Сохранено в галерею'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Ошибка сохранения: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final wardrobeItems = ref.watch(wardrobeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Гардероб'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          wardrobeItems.isEmpty
              ? const _EmptyWardrobeWidget()
              : _WardrobeGridView(
                  items: wardrobeItems,
                  onItemDoubleTap: _onItemDoubleTap,
                  onItemDelete: _deleteClothingItem,
                  onItemSave: _saveClothingToGallery,
                ),
          if (_isProcessing) const _ProcessingOverlay(),
        ],
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, _) {
          final isFabOpen = ref.watch(fabStateProvider);
          return _WardrobeFAB(
            isFabOpen: isFabOpen,
            onAIPressed: _showGenerateDialog,
            onCameraPressed: _showCameraOptions,
            onUploadPressed: _pickClothingImages,
            onToggleFAB: () {
              ref.read(fabStateProvider.notifier).state = !isFabOpen;
            },
          );
        },
      ),
    );
  }
}

// Виджет пустого гардероба
class _EmptyWardrobeWidget extends StatelessWidget {
  const _EmptyWardrobeWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checkroom_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'Гардероб пуст',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Добавьте одежду, чтобы начать',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms),
    );
  }
}

// Виджет сетки одежды
class _WardrobeGridView extends StatelessWidget {
  final List<ClothingItem> items;
  final Function(ClothingItem, GlobalKey) onItemDoubleTap;
  final Function(ClothingItem) onItemDelete;
  final Function(ClothingItem) onItemSave;

  const _WardrobeGridView({
    required this.items,
    required this.onItemDoubleTap,
    required this.onItemDelete,
    required this.onItemSave,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final itemKey = GlobalKey();
        return Draggable<String>(
          // Передаём ID и base64 через разделитель
          data: '${item.id}:${item.base64Image}',
          feedback: Material(
            color: Colors.transparent,
            child: Opacity(
              opacity: 0.7,
              child: Container(
                width: 150,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(
                    base64Decode(item.base64Image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: ClothingCardWidget(
              key: itemKey,
              item: item,
              onDoubleTap: () => onItemDoubleTap(item, itemKey),
              onDelete: () => onItemDelete(item),
              onSave: () => onItemSave(item),
            ),
          ),
          child: ClothingCardWidget(
            key: itemKey,
            item: item,
            onDoubleTap: () => onItemDoubleTap(item, itemKey),
            onDelete: () => onItemDelete(item),
            onSave: () => onItemSave(item),
          ),
        );
      },
    );
  }
}

// Виджет оверлея обработки
class _ProcessingOverlay extends StatelessWidget {
  const _ProcessingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// Виджет FAB с кнопками
class _WardrobeFAB extends StatelessWidget {
  final bool isFabOpen;
  final VoidCallback onAIPressed;
  final VoidCallback onCameraPressed;
  final VoidCallback onUploadPressed;
  final VoidCallback onToggleFAB;

  const _WardrobeFAB({
    required this.isFabOpen,
    required this.onAIPressed,
    required this.onCameraPressed,
    required this.onUploadPressed,
    required this.onToggleFAB,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isFabOpen) ...[
          _FABButton(
            heroTag: 'ai',
            backgroundColor: Colors.purple,
            icon: Icons.auto_awesome,
            onPressed: onAIPressed,
          ),
          const SizedBox(height: 12),
          _FABButton(
            heroTag: 'camera',
            backgroundColor: Colors.blue,
            icon: Icons.camera_alt,
            onPressed: onCameraPressed,
          ),
          const SizedBox(height: 12),
          _FABButton(
            heroTag: 'upload',
            backgroundColor: Colors.green,
            icon: Icons.photo_library,
            onPressed: onUploadPressed,
          ),
          const SizedBox(height: 12),
        ],
        FloatingActionButton(
          onPressed: onToggleFAB,
          child: AnimatedRotation(
            turns: isFabOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(isFabOpen ? Icons.close : Icons.add),
          ),
        ),
      ],
    );
  }
}

// Маленькая кнопка FAB
class _FABButton extends StatelessWidget {
  final String heroTag;
  final Color backgroundColor;
  final IconData icon;
  final VoidCallback onPressed;

  const _FABButton({
    required this.heroTag,
    required this.backgroundColor,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      mini: true,
      backgroundColor: backgroundColor,
      onPressed: onPressed,
      child: Icon(icon, color: Colors.white),
    ).animate().fadeIn(duration: 200.ms).scale(
          begin: const Offset(0.5, 0.5),
          duration: 200.ms,
        );
  }
}
