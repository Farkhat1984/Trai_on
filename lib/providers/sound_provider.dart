import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/sound_service.dart';

// Provider для состояния звуков (включены/выключены)
final soundEnabledProvider =
    StateNotifierProvider<SoundEnabledNotifier, bool>((ref) {
  return SoundEnabledNotifier();
});

class SoundEnabledNotifier extends StateNotifier<bool> {
  SoundEnabledNotifier() : super(true) {
    _loadSoundState();
  }

  Future<void> _loadSoundState() async {
    final box = Hive.box('settings');
    final enabled = box.get('soundEnabled', defaultValue: true) as bool;
    state = enabled;
    // Обновляем состояние в звуковом сервисе
    SoundService().setSoundsEnabled(enabled);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    state = enabled;
    final box = Hive.box('settings');
    await box.put('soundEnabled', enabled);
    // Обновляем состояние в звуковом сервисе
    SoundService().setSoundsEnabled(enabled);
  }
}
