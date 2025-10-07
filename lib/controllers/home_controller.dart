import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import '../services/api_service.dart';
import '../services/image_service.dart';
import '../models/app_exception.dart';

/// Controller for home screen business logic
class HomeController {
  final ApiService _apiService;
  final ImageService _imageService;

  HomeController({
    ApiService? apiService,
    ImageService? imageService,
  })  : _apiService = apiService ?? ApiService(),
        _imageService = imageService ?? ImageService();

  /// Pick person image from gallery
  Future<String?> pickPersonImageFromGallery() async {
    try {
      return await _imageService.pickImageFromGallery();
    } on ImageException {
      rethrow;
    } catch (error) {
      throw ImageException(
        message: 'Failed to pick image from gallery: $error',
        userMessage: 'Could not select image from gallery',
        originalError: error,
      );
    }
  }

  /// Take person photo with camera
  Future<String?> takePersonPhoto({bool useFrontCamera = false}) async {
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

  /// Generate person image from AI description
  Future<String> generatePersonFromDescription(String description) async {
    if (description.trim().isEmpty) {
      throw ValidationException(
        field: 'description',
        message: 'Description is empty',
        userMessage: 'Please enter a model description',
      );
    }

    try {
      return await _apiService.generatePersonImage(description);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(
        message: 'Failed to generate person image: $error',
        userMessage: 'Could not generate model. Please try again.',
        originalError: error,
      );
    }
  }

  /// Apply text-based changes to existing model
  Future<String> applyTextChangesToModel({
    required String personBase64,
    required String description,
  }) async {
    if (description.trim().isEmpty) {
      throw ValidationException(
        field: 'description',
        message: 'Description is empty',
        userMessage: 'Please enter description of changes',
      );
    }

    try {
      return await _apiService.applyClothingToModel(
        personBase64: personBase64,
        description: description,
      );
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(
        message: 'Failed to apply changes: $error',
        userMessage: 'Could not apply changes. Please try again.',
        originalError: error,
      );
    }
  }

  /// Apply clothing to model (virtual try-on)
  Future<String> applyClothingToModel({
    required String personBase64,
    required String clothingBase64,
    String? description,
  }) async {
    try {
      return await _apiService.applyClothingToModel(
        personBase64: personBase64,
        clothingBase64: clothingBase64,
        description: description,
      );
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(
        message: 'Failed to apply clothing: $error',
        userMessage: 'Could not apply clothing. Please try again.',
        originalError: error,
      );
    }
  }

  /// Share person image
  Future<void> shareImage(String base64Image) async {
    try {
      final bytes = base64Decode(base64Image);
      final xFile = XFile.fromData(
        bytes,
        name: 'virtual_try_on.png',
        mimeType: 'image/png',
      );

      // Use the legacy API for compatibility
      await Share.shareXFiles(
        [xFile],
        subject: 'Created in Virtual Try-On!',
      );
    } catch (error) {
      if (error is AppException) rethrow;
      throw ImageException(
        message: 'Failed to share image: $error',
        userMessage: 'Could not share image',
        originalError: error,
      );
    }
  }

  /// Save image to gallery
  Future<bool> saveImageToGallery(String base64Image) async {
    try {
      final bytes = base64Decode(base64Image);
      return await _imageService.saveImageToGallery(bytes);
    } on ImageSaveException {
      rethrow;
    } catch (error) {
      throw ImageSaveException(
        message: 'Failed to save to gallery: $error',
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
