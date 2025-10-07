import '../../constants/app_constants.dart';
import 'image_generation_service.dart';
import 'prompt_builder.dart';

/// High-level service for AI image generation operations
class AiImageService {
  final ImageGenerationService _generationService;

  AiImageService() : _generationService = ImageGenerationService();

  /// Generate a person image from description
  Future<String> generatePerson(String description) async {
    return await _generationService.generateImage(
      userPrompt: PromptBuilder.buildPersonPrompt(description),
      systemPrompt: PromptBuilder.personSystemPrompt,
      aspectRatio: AppConstants.aspectRatioPortrait,
    );
  }

  /// Generate a clothing image from description
  Future<String> generateClothing(String description) async {
    return await _generationService.generateImage(
      userPrompt: PromptBuilder.buildClothingPrompt(description),
      systemPrompt: PromptBuilder.clothingSystemPrompt,
      aspectRatio: AppConstants.aspectRatioSquare,
    );
  }

  /// Apply clothing to model (virtual try-on)
  Future<String> applyClothingToModel({
    required String personBase64,
    String? clothingBase64,
    String? description,
  }) async {
    final userPrompt = clothingBase64 != null
        ? PromptBuilder.buildTryOnPrompt(description: description)
        : PromptBuilder.buildModificationPrompt(description ?? '');

    return await _generationService.generateImage(
      personBase64: personBase64,
      clothingBase64: clothingBase64,
      userPrompt: userPrompt,
      systemPrompt: PromptBuilder.tryOnSystemPrompt,
      aspectRatio: AppConstants.aspectRatioPortrait,
    );
  }

  /// Dispose resources
  void dispose() {
    _generationService.dispose();
  }
}
