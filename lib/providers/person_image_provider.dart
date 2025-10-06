import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  PersonImageNotifier() : super(const PersonImageState());

  void setPersonImage(String base64Image, {bool isOriginal = true}) {
    if (isOriginal) {
      state = PersonImageState(
        base64Image: base64Image,
        originalBase64Image: base64Image,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        base64Image: base64Image,
        isLoading: false,
      );
    }
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void reset() {
    state = const PersonImageState();
  }

  void restoreOriginal() {
    if (state.originalBase64Image != null) {
      state = state.copyWith(
        base64Image: state.originalBase64Image,
      );
    }
  }
}
