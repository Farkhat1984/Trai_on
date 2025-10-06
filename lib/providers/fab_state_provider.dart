import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider для состояния FAB (Floating Action Button)
// Отдельный провайдер предотвращает пересборку всего экрана
final fabStateProvider = StateProvider.autoDispose<bool>((ref) => false);
