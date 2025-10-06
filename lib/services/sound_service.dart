import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Сервис для управления звуковыми эффектами
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  // Пулы аудио плееров для разных типов звуков
  final List<AudioPlayer> _clickPlayers = [];
  final List<AudioPlayer> _flyingPlayers = [];

  bool _isInitialized = false;
  bool _soundsEnabled = true;

  /// Инициализация звуковых эффектов
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Создаём пул плееров для звука клика (3 плеера для одновременных кликов)
      for (int i = 0; i < 3; i++) {
        final player = AudioPlayer();
        await player.setAsset('assets/sounds/click.wav');
        _clickPlayers.add(player);
      }

      // Создаём плеер для звука полёта (1 плеер, т.к. анимация одна)
      final flyingPlayer = AudioPlayer();
      await flyingPlayer.setAsset('assets/sounds/whoosh.wav');
      _flyingPlayers.add(flyingPlayer);

      _isInitialized = true;
    } catch (e) {
      // Если звуки не загрузились, продолжаем работу без них
      debugPrint('Sound initialization error: $e');
      _isInitialized = false;
    }
  }

  /// Включить/выключить звуки
  void setSoundsEnabled(bool enabled) {
    _soundsEnabled = enabled;
  }

  /// Проверка, включены ли звуки
  bool get soundsEnabled => _soundsEnabled;

  /// Воспроизвести звук клика кнопки
  Future<void> playClick() async {
    if (!_soundsEnabled || !_isInitialized) return;

    try {
      // Находим свободный плеер или тот, который уже закончил играть
      final player = _clickPlayers.firstWhere(
        (p) => !p.playing,
        orElse: () => _clickPlayers.first,
      );

      await player.seek(Duration.zero);
      await player.play();
    } catch (e) {
      debugPrint('Click sound error: $e');
    }
  }

  /// Воспроизвести длинный звук полёта с убыванием громкости
  Future<void> playFlying({Duration? duration}) async {
    if (!_soundsEnabled || !_isInitialized || _flyingPlayers.isEmpty) return;

    try {
      final player = _flyingPlayers.first;

      // Останавливаем предыдущее воспроизведение если оно было
      await player.stop();
      await player.seek(Duration.zero);

      // Устанавливаем начальную громкость
      await player.setVolume(0.8);

      // Запускаем воспроизведение
      await player.play();

      // Постепенно уменьшаем громкость в течение анимации
      if (duration != null) {
        _fadeOutVolume(player, duration);
      }
    } catch (e) {
      debugPrint('Flying sound error: $e');
    }
  }

  /// Плавное уменьшение громкости
  Future<void> _fadeOutVolume(AudioPlayer player, Duration duration) async {
    const steps = 20; // количество шагов уменьшения громкости
    final stepDuration = duration.inMilliseconds ~/ steps;

    for (int i = 1; i <= steps; i++) {
      await Future.delayed(Duration(milliseconds: stepDuration));
      final volume = 0.8 * (1 - (i / steps));
      try {
        await player.setVolume(volume);
      } catch (e) {
        break;
      }
    }
  }

  /// Очистка ресурсов
  Future<void> dispose() async {
    for (final player in _clickPlayers) {
      await player.dispose();
    }
    for (final player in _flyingPlayers) {
      await player.dispose();
    }
    _clickPlayers.clear();
    _flyingPlayers.clear();
    _isInitialized = false;
  }
}
