import 'package:flutter_riverpod/flutter_riverpod.dart';

class PersonImageState {
  final String? base64Image;
  final String? originalBase64Image;
  final bool isLoading;

  PersonImageState({
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
}

final personImageProvider = StateNotifierProvider<PersonImageNotifier, PersonImageState>((ref) {
  return PersonImageNotifier();
});

class PersonImageNotifier extends StateNotifier<PersonImageState> {
  PersonImageNotifier() : super(PersonImageState());

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
    state = PersonImageState();
  }

  void restoreOriginal() {
    if (state.originalBase64Image != null) {
      state = state.copyWith(
        base64Image: state.originalBase64Image,
      );
    }
  }
}
