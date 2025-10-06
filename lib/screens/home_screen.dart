import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/person_image_provider.dart';
import '../providers/selected_items_provider.dart';
import '../providers/fab_state_provider.dart';
import '../services/api_service.dart';
import '../services/image_service.dart';
import '../widgets/person_display_widget.dart';
import '../widgets/loading_overlay.dart';
import '../models/clothing_item.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _promptController = TextEditingController();
  final _apiService = ApiService();
  final _imageService = ImageService();

  bool _isProcessing = false;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _pickPersonImage() async {
    ref.read(fabStateProvider.notifier).state = false;
    try {
      final base64 = await _imageService.pickImageFromGallery();
      if (base64 != null) {
        ref.read(personImageProvider.notifier).setPersonImage(base64);
      }
    } catch (e) {
      _showError('Ошибка при загрузке изображения: $e');
    }
  }

  // Сразу запускаем заднюю камеру без выбора
  Future<void> _showCameraOptions() async {
    await _takePersonPhoto();
  }

  Future<void> _takePersonPhoto() async {
    try {
      // Всегда используем заднюю камеру (preferFrontCamera: false)
      final base64 =
          await _imageService.pickImageFromCamera(preferFrontCamera: false);
      if (base64 != null) {
        ref.read(personImageProvider.notifier).setPersonImage(base64);
      }
    } catch (e) {
      _showError('Ошибка при съемке фото: $e');
    }
  }

  Future<void> _generatePersonImage() async {
    final description = _promptController.text.trim();
    if (description.isEmpty) {
      _showError('Введите описание модели');
      return;
    }

    setState(() => _isProcessing = true);
    ref.read(personImageProvider.notifier).setLoading(true);

    try {
      final base64 = await _apiService.generatePersonImage(description);
      ref.read(personImageProvider.notifier).setPersonImage(base64);
      _promptController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Модель успешно создана!')),
        );
      }
    } catch (e) {
      _showError('Ошибка генерации: $e');
      ref.read(personImageProvider.notifier).setLoading(false);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showGeneratePersonDialog() {
    ref.read(fabStateProvider.notifier).state = false;
    final personState = ref.read(personImageProvider);
    final hasModel = personState.base64Image != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(hasModel ? 'Изменить модель с ИИ' : 'Создать модель с ИИ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasModel)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Опишите что изменить на текущей модели',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ),
            TextField(
              controller: _promptController,
              decoration: InputDecoration(
                hintText: hasModel
                    ? 'Например: поменять цвет футболки на синий'
                    : 'Опишите модель...',
                border: const OutlineInputBorder(),
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
              if (hasModel) {
                _applyTextChangesToModel();
              } else {
                _generatePersonImage();
              }
            },
            child: Text(hasModel ? 'Применить' : 'Создать'),
          ),
        ],
      ),
    );
  }

  Future<void> _applyTextChangesToModel() async {
    final personState = ref.read(personImageProvider);
    final description = _promptController.text.trim();

    if (description.isEmpty) {
      _showError('Введите описание изменений');
      return;
    }

    if (personState.base64Image == null) {
      _showError('Сначала создайте или загрузите модель');
      return;
    }

    setState(() => _isProcessing = true);
    ref.read(personImageProvider.notifier).setLoading(true);

    try {
      final base64 = await _apiService.applyClothingToModel(
        personBase64: personState.base64Image!,
        description: description,
      );

      ref
          .read(personImageProvider.notifier)
          .setPersonImage(base64, isOriginal: false);
      _promptController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Изменения применены!')),
        );
      }
    } catch (e) {
      _showError('Ошибка применения изменений: $e');
      ref.read(personImageProvider.notifier).setLoading(false);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _applyClothing(String clothingBase64) async {
    final personState = ref.read(personImageProvider);
    if (personState.base64Image == null) {
      _showError('Сначала загрузите или создайте модель!');
      return;
    }

    setState(() => _isProcessing = true);
    ref.read(personImageProvider.notifier).setLoading(true);

    try {
      final base64 = await _apiService.applyClothingToModel(
        personBase64: personState.base64Image!,
        clothingBase64: clothingBase64,
        description: _promptController.text.trim(),
      );

      ref
          .read(personImageProvider.notifier)
          .setPersonImage(base64, isOriginal: false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Примерка завершена!')),
        );
      }
    } catch (e) {
      _showError('Ошибка примерки: $e');
      ref.read(personImageProvider.notifier).setLoading(false);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _shareImage() async {
    final personState = ref.read(personImageProvider);
    if (personState.base64Image == null) return;

    try {
      final bytes = base64Decode(personState.base64Image!);
      await Share.shareXFiles(
        [
          XFile.fromData(bytes,
              name: 'virtual_try_on.png', mimeType: 'image/png')
        ],
        subject: 'Создано в Виртуальной примерочной!',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Изображение отправлено'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Ошибка при попытке поделиться: $e');
    }
  }

  Future<void> _saveToGallery() async {
    final personState = ref.read(personImageProvider);
    if (personState.base64Image == null) return;

    try {
      final bytes = base64Decode(personState.base64Image!);
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

  void _deletePersonImage() {
    ref.read(fabStateProvider.notifier).state = false;
    ref.read(personImageProvider.notifier).reset();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Изображение удалено'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  @override
  Widget build(BuildContext context) {
    final personState = ref.watch(personImageProvider);
    final selectedItems = ref.watch(selectedItemsProvider);
    final isFabOpen = ref.watch(fabStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Виртуальная примерочная'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child:
                                _buildPersonSection(personState, constraints),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (selectedItems.isNotEmpty) _buildCarousel(selectedItems),
            ],
          ),
          if (_isProcessing || personState.isLoading) const LoadingOverlay(),
        ],
      ),
      floatingActionButton: _HomeFAB(
        isFabOpen: isFabOpen,
        hasPersonImage: personState.base64Image != null,
        onDeletePressed: _deletePersonImage,
        onSavePressed: _saveToGallery,
        onSharePressed: _shareImage,
        onAIPressed: _showGeneratePersonDialog,
        onCameraPressed: _showCameraOptions,
        onUploadPressed: _pickPersonImage,
        onToggleFAB: () {
          ref.read(fabStateProvider.notifier).state = !isFabOpen;
        },
      ),
    );
  }

  Widget _buildPersonSection(
      PersonImageState personState, BoxConstraints constraints) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: PersonDisplayWidget(
          onClothingDropped: _applyClothing,
        ).animate().fadeIn(duration: 300.ms),
      ),
    );
  }

  Widget _buildCarousel(List<ClothingItem> items) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onDoubleTap: () => _applyClothing(item.base64Image),
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(
                    base64Decode(item.base64Image),
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          ref
                              .read(selectedItemsProvider.notifier)
                              .removeItem(item.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Удалено из выбранных'),
                              duration: Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.delete,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 200.ms).scale(
                  begin: const Offset(0.8, 0.8),
                  duration: 200.ms,
                ),
          );
        },
      ),
    );
  }
}

// Виджет FAB для главного экрана
class _HomeFAB extends StatelessWidget {
  final bool isFabOpen;
  final bool hasPersonImage;
  final VoidCallback onDeletePressed;
  final VoidCallback onSavePressed;
  final VoidCallback onSharePressed;
  final VoidCallback onAIPressed;
  final VoidCallback onCameraPressed;
  final VoidCallback onUploadPressed;
  final VoidCallback onToggleFAB;

  const _HomeFAB({
    required this.isFabOpen,
    required this.hasPersonImage,
    required this.onDeletePressed,
    required this.onSavePressed,
    required this.onSharePressed,
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
          if (hasPersonImage) ...[
            _HomeFABButton(
              heroTag: 'delete',
              backgroundColor: Colors.red,
              icon: Icons.delete_outline,
              onPressed: onDeletePressed,
            ),
            const SizedBox(height: 12),
            _HomeFABButton(
              heroTag: 'save',
              backgroundColor: Colors.orange,
              icon: Icons.save_alt,
              onPressed: onSavePressed,
            ),
            const SizedBox(height: 12),
            _HomeFABButton(
              heroTag: 'share',
              backgroundColor: Colors.teal,
              icon: Icons.share,
              onPressed: onSharePressed,
            ),
            const SizedBox(height: 12),
          ],
          _HomeFABButton(
            heroTag: 'ai',
            backgroundColor: Colors.purple,
            icon: Icons.auto_awesome,
            onPressed: onAIPressed,
          ),
          const SizedBox(height: 12),
          _HomeFABButton(
            heroTag: 'camera',
            backgroundColor: Colors.blue,
            icon: Icons.camera_alt,
            onPressed: onCameraPressed,
          ),
          const SizedBox(height: 12),
          _HomeFABButton(
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

// Маленькая кнопка FAB для главного экрана
class _HomeFABButton extends StatelessWidget {
  final String heroTag;
  final Color backgroundColor;
  final IconData icon;
  final VoidCallback onPressed;

  const _HomeFABButton({
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
