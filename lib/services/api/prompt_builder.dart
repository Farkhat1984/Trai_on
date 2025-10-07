/// Builder class for creating AI prompts
class PromptBuilder {
  PromptBuilder._();

  /// System prompt for person image generation
  static const String personSystemPrompt =
      "You are an AI photographer specializing in professional fashion photography. "
      "Generate ONLY images, never text. Create photorealistic, high-quality full-body portraits. "
      "Use studio lighting, maintain sharp focus, and ensure professional composition.";

  /// System prompt for clothing image generation
  static const String clothingSystemPrompt =
      "You are an AI product photographer specializing in e-commerce clothing photography. "
      "Generate ONLY images, never text. Create clean, professional product photos with perfect lighting.";

  /// System prompt for virtual try-on
  static const String tryOnSystemPrompt =
      "You are a professional AI fashion photographer and virtual stylist. "
      "Generate ONLY photorealistic images, never text. "
      "Your specialty is creating seamless, natural-looking virtual clothing try-ons while preserving the person's identity perfectly.";

  /// Build user prompt for generating a person image
  static String buildPersonPrompt(String description) {
    return 'Create a photorealistic full-body portrait of a model in a vertical 2:3 composition. '
        'The model should be: $description. '
        'Use professional studio lighting with soft shadows, neutral background, '
        'and ensure the model is centered in the frame. The image must be in portrait orientation (832x1248 pixels).';
  }

  /// Build user prompt for generating clothing image
  static String buildClothingPrompt(String description) {
    return 'Create a high-resolution, studio-lit product photograph of clothing item: $description. '
        'The item should be centered on a clean white background. '
        'Use even, diffused lighting to eliminate harsh shadows and showcase details. '
        'Square composition (1024x1024 pixels) suitable for e-commerce display.';
  }

  /// Build user prompt for applying clothing to model
  static String buildTryOnPrompt({String? description}) {
    return 'This is a professional e-commerce fashion photoshoot. '
        'Take the clothing item from the second image and dress the person from the first image in it. '
        'The result should look like a natural studio photograph where the person is actually wearing this exact clothing. '
        'The person\'s face, hair, eyes, skin tone, and body proportions remain completely unchanged - they are the same person. '
        'The clothing fits naturally on their body with realistic fabric texture, wrinkles, and shadows that match the studio lighting. '
        'The background, pose, and camera angle stay identical to the original portrait. '
        '${description != null && description.isNotEmpty ? description : ""}'
        .trim();
  }

  /// Build user prompt for text-based modifications to model
  static String buildModificationPrompt(String description) {
    return 'This is a photo editing task for a professional portrait. '
        'Apply these changes to the person in the image: $description. '
        'The person\'s identity must remain completely unchanged - same face, same eyes, same hair, same skin. '
        'Only the specified changes are applied, everything else stays exactly as in the original photo.';
  }
}
