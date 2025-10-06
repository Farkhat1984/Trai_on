import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/person_image_provider.dart';

class PersonDisplayWidget extends ConsumerStatefulWidget {
  final Function(String clothingBase64) onClothingDropped;
  final GlobalKey? targetKey;

  const PersonDisplayWidget({
    super.key,
    required this.onClothingDropped,
    this.targetKey,
  });

  @override
  ConsumerState<PersonDisplayWidget> createState() =>
      _PersonDisplayWidgetState();
}

class _PersonDisplayWidgetState extends ConsumerState<PersonDisplayWidget> {
  bool _isDraggingOver = false;
  String? _animatingClothingId;

  void _handleClothingDrop(String clothingData) {
    // Извлекаем ID одежды из данных (формат: "id:base64")
    final parts = clothingData.split(':');
    if (parts.length == 2) {
      setState(() => _animatingClothingId = parts[0]);

      // Ждём завершения Hero анимации перед применением
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() => _animatingClothingId = null);
          widget.onClothingDropped(parts[1]); // Передаём только base64
        }
      });
    } else {
      // Fallback на старый формат
      widget.onClothingDropped(clothingData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final personState = ref.watch(personImageProvider);

    return Stack(
      children: [
        DragTarget<String>(
          onWillAcceptWithDetails: (details) {
            if (!_isDraggingOver) {
              setState(() => _isDraggingOver = true);
            }
            return personState.base64Image != null;
          },
          onLeave: (_) {
            if (_isDraggingOver) {
              setState(() => _isDraggingOver = false);
            }
          },
          onAcceptWithDetails: (details) {
            setState(() => _isDraggingOver = false);
            _handleClothingDrop(details.data);
          },
          builder: (context, candidateData, rejectedData) {
            return AnimatedContainer(
              key: widget.targetKey,
              duration: const Duration(milliseconds: 300),
              constraints: const BoxConstraints(
                minHeight: 400,
                maxHeight: 600,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: _isDraggingOver
                    ? Border.all(
                        color: Colors.blue.withValues(alpha: 0.8),
                        width: 3,
                      )
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: personState.isLoading
                    ? const _LoadingState()
                    : personState.base64Image != null
                        ? _ImageState(base64Image: personState.base64Image!)
                        : const _PlaceholderState(),
              ),
            );
          },
        ),
        // Hero destination для анимации одежды
        if (_animatingClothingId != null)
          Positioned.fill(
            child: Hero(
              tag: 'clothing_$_animatingClothingId',
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Виджет состояния загрузки
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Магия в процессе...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Подбираем ваш новый образ!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ].animate(interval: 100.ms).fadeIn().slideY(begin: 0.2),
      ),
    );
  }
}

// Виджет для отображения изображения
class _ImageState extends StatelessWidget {
  final String base64Image;

  const _ImageState({required this.base64Image});

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      base64Decode(base64Image),
      fit: BoxFit.cover,
      gaplessPlayback: true,
      cacheWidth: 800,
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9));
  }
}

// Виджет placeholder состояния
class _PlaceholderState extends StatelessWidget {
  const _PlaceholderState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_camera_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Сгенерируйте модель или загрузите фото',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Введите описание в поле ниже или нажмите кнопку',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
        ].animate(interval: 100.ms).fadeIn().slideY(begin: 0.2),
      ),
    );
  }
}
