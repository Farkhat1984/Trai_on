import '../services/api_service.dart';
import '../services/image_service.dart';
import '../models/app_exception.dart';

/// Controller for wardrobe screen business logic
class WardrobeController {
  final ApiService _apiService;
  final ImageService _imageService;

  WardrobeController({
    ApiService? apiService,
    ImageService? imageService,
  })  : _apiService = apiService ?? ApiService(),
        _imageService = imageService ?? ImageService();

  /// Pick multiple clothing images from gallery
  Future<List<String>> pickClothingImagesFromGallery() async {
    try {
      return await _imageService.pickMultipleImagesFromGallery();
    } on ImageException {
      rethrow;
    } catch (error) {
      throw ImageException(
        message: 'Failed to pick images from gallery: $error',
        userMessage: 'Could not select images from gallery',
        originalError: error,
      );
    }
  }

  /// Take clothing photo with camera
  Future<String?> takeClothingPhoto({bool useFrontCamera = false}) async {
    try {
      return await _imageService.pickImageFromCamera(
        preferFrontCamera: useFrontCamera,
      );
    } on ImageException {
      rethrow;
    } catch (error) {
      throw ImageException(
        message: 'Failed to take photo: $error',
        userMessage: 'Could not take photo',
        originalError: error,
      );
    }
  }

  /// Generate clothing image from AI description
  Future<String> generateClothingFromDescription(String description) async {
    if (description.trim().isEmpty) {
      throw ValidationException(
        field: 'description',
        message: 'Description is empty',
        userMessage: 'Please enter a clothing description',
      );
    }

    try {
      return await _apiService.generateClothingImage(description);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(
        message: 'Failed to generate clothing image: $error',
        userMessage: 'Could not generate clothing. Please try again.',
        originalError: error,
      );
    }
  }

  /// Get user-friendly error message from exception
  String getErrorMessage(Object error) {
    if (error is AppException) {
      return error.getUserMessage();
    }
    return 'An unexpected error occurred';
  }

  /// Dispose resources
  void dispose() {
    _apiService.dispose();
  }
}
