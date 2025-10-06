import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Сервис для создания анимации "летящего" виджета
/// Использует Overlay для отображения виджета поверх всех элементов
class FlyingWidgetService {
  /// Запускает анимацию полёта изображения из исходной точки к целевой
  static void flyWidget({
    required BuildContext context,
    required GlobalKey sourceKey,
    required GlobalKey targetKey,
    required String imageBase64,
    Offset targetOffset = Offset.zero,
    Duration duration = const Duration(milliseconds: 800),
    VoidCallback? onComplete,
  }) {
    // Получаем координаты исходного виджета
    final RenderBox? sourceBox =
        sourceKey.currentContext?.findRenderObject() as RenderBox?;
    if (sourceBox == null) return;

    // Получаем координаты целевого виджета
    final RenderBox? targetBox =
        targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (targetBox == null) return;

    // Преобразуем в глобальные координаты
    final sourcePosition = sourceBox.localToGlobal(Offset.zero);
    final sourceSize = sourceBox.size;
    final targetPosition = targetBox.localToGlobal(Offset.zero);
    final targetSize = targetBox.size;

    // Вычисляем центры
    final sourceCenter = Offset(
      sourcePosition.dx + sourceSize.width / 2,
      sourcePosition.dy + sourceSize.height / 2,
    );
    final targetCenter = Offset(
      targetPosition.dx + targetSize.width / 2,
      targetPosition.dy + targetSize.height / 2,
    );
    final adjustedTargetCenter = targetCenter + targetOffset;

    // Создаём overlay entry
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _FlyingWidget(
        imageBase64: imageBase64,
        startPosition: sourceCenter,
        endPosition: adjustedTargetCenter,
        startSize: sourceSize,
        endSize: targetSize,
        duration: duration,
        onComplete: () {
          overlayEntry.remove();
          onComplete?.call();
        },
      ),
    );

    overlay.insert(overlayEntry);
  }
}

/// Виджет, который отображает летящее изображение
class _FlyingWidget extends StatefulWidget {
  final String imageBase64;
  final Offset startPosition;
  final Offset endPosition;
  final Size startSize;
  final Size endSize;
  final Duration duration;
  final VoidCallback onComplete;

  const _FlyingWidget({
    required this.imageBase64,
    required this.startPosition,
    required this.endPosition,
    required this.startSize,
    required this.endSize,
    required this.duration,
    required this.onComplete,
  });

  @override
  State<_FlyingWidget> createState() => _FlyingWidgetState();
}

class _FlyingWidgetState extends State<_FlyingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late final Uint8List _imageBytes;

  @override
  void initState() {
    super.initState();

    _imageBytes = base64Decode(widget.imageBase64);

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Анимация позиции с кривой easeInOut
    _positionAnimation = Tween<Offset>(
      begin: widget.startPosition,
      end: widget.endPosition,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));

    // Анимация масштаба (уменьшение)
    final scaleRatio =
        (widget.endSize.width / widget.startSize.width).clamp(0.1, 1.0);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: scaleRatio,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Анимация прозрачности
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.8),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 0.3),
        weight: 50,
      ),
    ]).animate(_controller);

    // Запускаем анимацию
    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx -
              (widget.startSize.width / 2 * _scaleAnimation.value),
          top: _positionAnimation.value.dy -
              (widget.startSize.height / 2 * _scaleAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.startSize.width,
              height: widget.startSize.height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.3 * _opacityAnimation.value,
                    ),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Image.memory(
                    _imageBytes,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
