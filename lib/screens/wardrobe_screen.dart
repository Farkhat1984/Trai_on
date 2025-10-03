import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/wardrobe_provider.dart';
import '../providers/selected_items_provider.dart';
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
  bool _isFabOpen = false;

  @override
  void dispose() {
    _clothingPromptController.dispose();
    super.dispose();
  }

  Future<void> _pickClothingImages() async {
    setState(() => _isFabOpen = false);
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
    setState(() => _isFabOpen = false);
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
    setState(() => _isFabOpen = false);
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
    setState(() => _isFabOpen = false);
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

  void _onItemDoubleTap(ClothingItem item) {
    ref.read(selectedItemsProvider.notifier).addItem(item);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Добавлено в выбранные'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
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
              ? Center(
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
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: wardrobeItems.length,
                  itemBuilder: (context, index) {
                    final item = wardrobeItems[index];
                    return ClothingCardWidget(
                      item: item,
                      onDoubleTap: () => _onItemDoubleTap(item),
                      onDelete: () => _deleteClothingItem(item),
                      onSave: () => _saveClothingToGallery(item),
                    );
                  },
                ),
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isFabOpen) ...[
            FloatingActionButton(
              heroTag: 'ai',
              mini: true,
              backgroundColor: Colors.purple,
              onPressed: _showGenerateDialog,
              child: const Icon(Icons.auto_awesome, color: Colors.white),
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              heroTag: 'camera',
              mini: true,
              backgroundColor: Colors.blue,
              onPressed: _showCameraOptions,
              child: const Icon(Icons.camera_alt, color: Colors.white),
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              heroTag: 'upload',
              mini: true,
              backgroundColor: Colors.green,
              onPressed: _pickClothingImages,
              child: const Icon(Icons.photo_library, color: Colors.white),
            ),
            const SizedBox(height: 12),
          ],
          FloatingActionButton(
            onPressed: () {
              setState(() => _isFabOpen = !_isFabOpen);
            },
            child: AnimatedRotation(
              turns: _isFabOpen ? 0.125 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(_isFabOpen ? Icons.close : Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
