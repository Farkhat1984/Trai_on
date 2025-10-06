import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider для управления индексом навигации
final navigationIndexProvider = StateProvider<int>((ref) => 0);
