import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';

class TryOnAnimationOverlay extends StatefulWidget {
  final String clothingBase64;
  final VoidCallback onComplete;

  const TryOnAnimationOverlay({
    super.key,
    required this.clothingBase64,
    required this.onComplete,
  });

  @override
  State<TryOnAnimationOverlay> createState() => _TryOnAnimationOverlayState();
}

class _TryOnAnimationOverlayState extends State<TryOnAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000), // Сократили с 1200 до 1000
      vsync: this,
    );

    // Анимация масштаба: начинаем с 1.0, уменьшаемся до 0.2, останавливаемся
    // Убрали финальную фазу уменьшения до 0
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.5)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: 0.2)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_controller);

    // Анимация позиции: летим вверх и в центр (без финальной фазы)
    _positionAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0, -0.3),
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0, -0.3),
          end: const Offset(0, -0.4),
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_controller);

    // Анимация прозрачности: останавливаемся на 0.3 вместо 0
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
        return Positioned.fill(
          child: IgnorePointer(
            child: Stack(
              children: [
                // Фоновое затемнение
                Container(
                  color: Colors.black.withValues(
                    alpha: 0.3 * (1 - _controller.value),
                  ),
                ),
                // Анимирующееся изображение одежды
                // Скрываем после 50% анимации (когда начинается celebrate)
                if (_controller.value < 0.5)
                  Center(
                    child: Transform.translate(
                      offset: Offset(
                        0,
                        _positionAnimation.value.dy *
                            MediaQuery.of(context).size.height,
                      ),
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 200,
                          height: 250,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                    alpha: 0.3 * _opacityAnimation.value),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Opacity(
                              opacity: _opacityAnimation.value,
                              child: Image.memory(
                                base64Decode(widget.clothingBase64),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                // Частицы эффекта "магии"
                if (_controller.value > 0.5) ..._buildMagicParticles(context),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildMagicParticles(BuildContext context) {
    final particleProgress = (_controller.value - 0.5) * 2;
    return List.generate(12, (index) {
      final angle = (index / 12) * 2 * pi;
      final radius = 100 * particleProgress;

      return Positioned(
        left: MediaQuery.of(context).size.width / 2 + radius * cos(angle) - 4,
        top: MediaQuery.of(context).size.height / 2 -
            100 +
            radius * sin(angle) -
            4,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withValues(alpha: 0.6 * (1 - particleProgress)),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.blue.withValues(alpha: 0.3 * (1 - particleProgress)),
                blurRadius: 4,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      );
    });
  }
}
