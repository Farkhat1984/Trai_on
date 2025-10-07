import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider для управления состоянием раскрытия корзины
final cartExpandedProvider = StateProvider<bool>((ref) => false);
