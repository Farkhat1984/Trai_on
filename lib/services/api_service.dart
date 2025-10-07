import 'api/ai_image_service.dart';

/// Legacy API Service - delegates to new refactored services
/// Maintained for backward compatibility with existing code
class ApiService {
  final AiImageService _aiImageService;

  ApiService() : _aiImageService = AiImageService();

  /// Generate a person image from description
  Future<String> generatePersonImage(String description) async {
    return await _aiImageService.generatePerson(description);
  }

  /// Generate a clothing image from description
  Future<String> generateClothingImage(String description) async {
    return await _aiImageService.generateClothing(description);
  }

  /// Apply clothing to model (virtual try-on)
  Future<String> applyClothingToModel({
    required String personBase64,
    String? clothingBase64,
    String? description,
  }) async {
    return await _aiImageService.applyClothingToModel(
      personBase64: personBase64,
      clothingBase64: clothingBase64,
      description: description,
    );
  }

  /// Dispose resources
  void dispose() {
    _aiImageService.dispose();
  }
}
