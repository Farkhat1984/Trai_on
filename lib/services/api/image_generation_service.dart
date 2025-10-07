import 'package:dio/dio.dart';
import '../../config/env_config.dart';
import '../../constants/app_constants.dart';
import '../../models/app_exception.dart';
import '../../utils/logger.dart';
import 'retry_policy.dart';

/// Service for handling image generation API calls
class ImageGenerationService {
  final Dio _dio;

  ImageGenerationService()
      : _dio = Dio(
          BaseOptions(
            connectTimeout: AppConstants.apiConnectTimeout,
            receiveTimeout: AppConstants.apiReceiveTimeout,
          ),
        );

  /// Generate image from API
  Future<String> generateImage({
    String? personBase64,
    String? clothingBase64,
    required String userPrompt,
    required String systemPrompt,
    String aspectRatio = AppConstants.aspectRatioPortrait,
  }) async {
    final List<Map<String, dynamic>> payloadParts = [];

    // Add images first, then text
    if (personBase64 != null) {
      payloadParts.add({
        'inlineData': {
          'mimeType': 'image/png',
          'data': personBase64,
        },
      });
    }

    if (clothingBase64 != null) {
      payloadParts.add({
        'inlineData': {
          'mimeType': 'image/png',
          'data': clothingBase64,
        },
      });
    }

    payloadParts.add({'text': userPrompt});

    final payload = {
      'contents': [
        {'parts': payloadParts}
      ],
      'systemInstruction': {
        'parts': [
          {'text': systemPrompt}
        ]
      },
      'generationConfig': {
        'temperature': AppConstants.generationTemperature,
        'topK': AppConstants.generationTopK,
        'topP': AppConstants.generationTopP,
        'maxOutputTokens': AppConstants.generationMaxOutputTokens,
        'responseModalities': ['IMAGE'],
        'imageConfig': {
          'aspectRatio': aspectRatio,
        },
      },
    };

    final retryPolicy = RetryPolicy();

    while (retryPolicy.shouldRetry()) {
      retryPolicy.incrementAttempt();

      try {
        logger.d('Attempt ${retryPolicy.attempts} of ${retryPolicy.maxAttempts}...');

        final response = await _dio.post(
          '${EnvConfig.geminiEndpoint}?key=${EnvConfig.googleAiApiKey}',
          data: payload,
          options: Options(
            headers: {'Content-Type': 'application/json'},
          ),
        );

        if (response.statusCode == 200) {
          return _processSuccessResponse(response.data);
        }

        return _handleErrorResponse(response, retryPolicy);
      } on DioException catch (e) {
        return await _handleDioException(e, retryPolicy);
      } catch (error) {
        if (retryPolicy.shouldRetry()) {
          logger.d('Unexpected error: $error, retrying...');
          await retryPolicy.waitAndIncreaseDelay();
          continue;
        }
        throw ApiException(
          message: 'Unexpected error: $error',
          endpoint: EnvConfig.geminiEndpoint,
          originalError: error,
        );
      }
    }

    throw ApiException(
      message: 'Failed to get response after ${retryPolicy.maxAttempts} attempts',
      userMessage: 'Could not generate image. Please try again later.',
      endpoint: EnvConfig.geminiEndpoint,
    );
  }

  String _processSuccessResponse(Map<String, dynamic> result) {
    // Check for content blocking
    if (result['promptFeedback']?['blockReason'] != null) {
      final blockReason = result['promptFeedback']['blockReason'];
      final safetyRatings = result['promptFeedback']?['safetyRatings'];
      throw ApiContentBlockedException(
        message: 'Content blocked: $blockReason',
        blockReason: blockReason,
        safetyRatings: safetyRatings,
        endpoint: EnvConfig.geminiEndpoint,
      );
    }

    // Check for candidates
    if (result['candidates'] == null || (result['candidates'] as List).isEmpty) {
      throw ApiInvalidResponseException(
        message: 'No candidates in response',
        endpoint: EnvConfig.geminiEndpoint,
      );
    }

    final candidates = result['candidates'] as List;
    final finishReason = candidates[0]['finishReason'];

    // Check for safety filter
    if (finishReason == 'SAFETY') {
      throw ApiContentBlockedException(
        message: 'Content blocked by safety filter',
        blockReason: 'SAFETY',
        safetyRatings: candidates[0]['safetyRatings'],
        endpoint: EnvConfig.geminiEndpoint,
      );
    }

    final parts = candidates[0]['content']?['parts'] as List?;
    if (parts == null || parts.isEmpty) {
      throw ApiInvalidResponseException(
        message: 'Empty parts in response',
        endpoint: EnvConfig.geminiEndpoint,
      );
    }

    // Find image in response
    for (var part in parts) {
      if (part['inlineData'] != null && part['inlineData']['data'] != null) {
        return part['inlineData']['data'] as String;
      }
    }

    throw ApiInvalidResponseException(
      message: 'No image found in response',
      endpoint: EnvConfig.geminiEndpoint,
    );
  }

  Future<String> _handleErrorResponse(
      Response response, RetryPolicy retryPolicy) async {
    if (response.statusCode == 429) {
      if (retryPolicy.shouldRetry()) {
        await retryPolicy.waitAndIncreaseDelay();
        return ''; // Will retry in loop
      }
      throw ApiRateLimitException(endpoint: EnvConfig.geminiEndpoint);
    }

    if (response.statusCode == 503) {
      if (retryPolicy.shouldRetry()) {
        await retryPolicy.waitDoubledDelay();
        return ''; // Will retry in loop
      }
      throw ApiServiceUnavailableException(endpoint: EnvConfig.geminiEndpoint);
    }

    throw ApiException(
      message: 'API error: ${response.statusCode}',
      statusCode: response.statusCode,
      endpoint: EnvConfig.geminiEndpoint,
    );
  }

  Future<String> _handleDioException(
      DioException e, RetryPolicy retryPolicy) async {
    if (retryPolicy.shouldRetry()) {
      await retryPolicy.waitAndIncreaseDelay();
      return ''; // Will retry in loop
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw ApiTimeoutException(endpoint: EnvConfig.geminiEndpoint);
    }

    throw NetworkException(
      message: 'Network error: ${e.message}',
      originalError: e,
    );
  }

  /// Dispose resources
  void dispose() {
    _dio.close();
  }
}
