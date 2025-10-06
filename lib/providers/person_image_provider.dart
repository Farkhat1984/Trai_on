import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PersonImageState {
  final String? base64Image;
  final String? originalBase64Image;
  final bool isLoading;

  const PersonImageState({
    this.base64Image,
    this.originalBase64Image,
    this.isLoading = false,
  });

  PersonImageState copyWith({
    String? base64Image,
    String? originalBase64Image,
    bool? isLoading,
  }) {
    return PersonImageState(
      base64Image: base64Image ?? this.base64Image,
      originalBase64Image: originalBase64Image ?? this.originalBase64Image,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonImageState &&
          runtimeType == other.runtimeType &&
          base64Image == other.base64Image &&
          originalBase64Image == other.originalBase64Image &&
          isLoading == other.isLoading;

  @override
  int get hashCode =>
      base64Image.hashCode ^ originalBase64Image.hashCode ^ isLoading.hashCode;
}

final personImageProvider =
    StateNotifierProvider<PersonImageNotifier, PersonImageState>((ref) {
  return PersonImageNotifier();
});

// Селекторы для оптимизации - подписываемся только на нужные части состояния
final personImageBase64Provider = Provider<String?>((ref) {
  return ref.watch(personImageProvider.select((state) => state.base64Image));
});

final personImageLoadingProvider = Provider<bool>((ref) {
  return ref.watch(personImageProvider.select((state) => state.isLoading));
});

final hasPersonImageProvider = Provider<bool>((ref) {
  return ref
      .watch(personImageProvider.select((state) => state.base64Image != null));
});

class PersonImageNotifier extends StateNotifier<PersonImageState> {
  PersonImageNotifier() : super(const PersonImageState()) {
    _loadPersonImage();
  }

  // Загружаем сохранённое изображение модели при инициализации
  Future<void> _loadPersonImage() async {
    final box = Hive.box('settings');
    final savedImage = box.get('person_image') as String?;
    final savedOriginal = box.get('person_original_image') as String?;

    if (savedImage != null) {
      state = PersonImageState(
        base64Image: savedImage,
        originalBase64Image: savedOriginal ?? savedImage,
        isLoading: false,
      );
    }
  }

  Future<void> setPersonImage(String base64Image,
      {bool isOriginal = true}) async {
    final box = Hive.box('settings');

    if (isOriginal) {
      // Сохраняем и текущее, и оригинальное изображение
      await box.put('person_image', base64Image);
      await box.put('person_original_image', base64Image);

      state = PersonImageState(
        base64Image: base64Image,
        originalBase64Image: base64Image,
        isLoading: false,
      );
    } else {
      // Сохраняем только текущее изображение (после примерки)
      await box.put('person_image', base64Image);

      state = state.copyWith(
        base64Image: base64Image,
        isLoading: false,
      );
    }
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  Future<void> reset() async {
    final box = Hive.box('settings');
    await box.delete('person_image');
    await box.delete('person_original_image');
    state = const PersonImageState();
  }

  Future<void> restoreOriginal() async {
    if (state.originalBase64Image != null) {
      final box = Hive.box('settings');
      await box.put('person_image', state.originalBase64Image);

      state = state.copyWith(
        base64Image: state.originalBase64Image,
      );
    }
  }
}
