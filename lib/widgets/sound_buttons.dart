import 'package:flutter/material.dart';
import '../services/sound_service.dart';

/// Обёртка для FloatingActionButton с звуковым эффектом клика
class SoundFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final String? heroTag;
  final bool? mini;
  final Color? backgroundColor;

  const SoundFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.heroTag,
    this.mini,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      mini: mini ?? false,
      backgroundColor: backgroundColor,
      onPressed: () {
        SoundService().playClick();
        onPressed();
      },
      child: child,
    );
  }
}

/// Обёртка для ElevatedButton с звуковым эффектом клика
class SoundElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const SoundElevatedButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        SoundService().playClick();
        onPressed();
      },
      child: child,
    );
  }
}

/// Обёртка для TextButton с звуковым эффектом клика
class SoundTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final ButtonStyle? style;

  const SoundTextButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: style,
      onPressed: () {
        SoundService().playClick();
        onPressed();
      },
      child: child,
    );
  }
}

/// Обёртка для IconButton с звуковым эффектом клика
class SoundIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final double? iconSize;
  final Color? color;

  const SoundIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.iconSize,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: iconSize,
      color: color,
      onPressed: () {
        SoundService().playClick();
        onPressed();
      },
      icon: icon,
    );
  }
}

/// Миксин для добавления звука к onTap в любом виджете
mixin SoundOnTapMixin {
  void onTapWithSound(VoidCallback callback) {
    SoundService().playClick();
    callback();
  }
}
