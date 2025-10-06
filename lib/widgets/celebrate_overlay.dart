import 'dart:math';
import 'package:flutter/material.dart';

/// Оверлей с celebrate эффектом (магические частицы)
/// Показывается ПОСЛЕ успешной генерации изображения
class CelebrateOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const CelebrateOverlay({
    super.key,
    required this.onComplete,
  });

  @override
  State<CelebrateOverlay> createState() => _CelebrateOverlayState();
}

class _CelebrateOverlayState extends State<CelebrateOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

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
                ..._buildMagicParticles(context),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildMagicParticles(BuildContext context) {
    final particleProgress = _controller.value;
    return List.generate(16, (index) {
      final angle = (index / 16) * 2 * pi;
      final radius = 120 * particleProgress;

      return Positioned(
        left: MediaQuery.of(context).size.width / 2 + radius * cos(angle) - 6,
        top: MediaQuery.of(context).size.height / 2 -
            150 +
            radius * sin(angle) -
            6,
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.blue.withValues(alpha: 0.8 * (1 - particleProgress)),
                Colors.purple.withValues(alpha: 0.6 * (1 - particleProgress)),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.blue.withValues(alpha: 0.4 * (1 - particleProgress)),
                blurRadius: 8,
                spreadRadius: 3,
              ),
            ],
          ),
        ),
      );
    });
  }
}
