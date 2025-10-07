/// Base class for all application exceptions
abstract class AppException implements Exception {
  final String message;
  final String? userMessage;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppException({
    required this.message,
    this.userMessage,
    this.originalError,
    this.stackTrace,
  });

  /// Get user-friendly message (fallback to technical message if not provided)
  String getUserMessage() => userMessage ?? message;

  @override
  String toString() => 'AppException: $message';
}

/// API-related exceptions
class ApiException extends AppException {
  final int? statusCode;
  final String? endpoint;

  ApiException({
    required super.message,
    super.userMessage,
    this.statusCode,
    this.endpoint,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() =>
      'ApiException(${statusCode ?? 'unknown'}): $message at $endpoint';
}

/// API timeout exception
class ApiTimeoutException extends ApiException {
  ApiTimeoutException({
    super.message = 'Request timed out',
    super.userMessage = 'Request took too long. Please check your internet connection.',
    super.endpoint,
  });
}

/// API rate limit exceeded
class ApiRateLimitException extends ApiException {
  ApiRateLimitException({
    super.message = 'Rate limit exceeded',
    super.userMessage =
        'Too many requests. Please wait a few minutes and try again.',
    super.statusCode = 429,
    super.endpoint,
  });
}

/// API content blocked by safety filters
class ApiContentBlockedException extends ApiException {
  final String? blockReason;
  final List<dynamic>? safetyRatings;

  ApiContentBlockedException({
    required super.message,
    super.userMessage =
        'Content blocked by safety filters. Please use different images or descriptions.',
    this.blockReason,
    this.safetyRatings,
    super.endpoint,
  });

  @override
  String toString() => 'ApiContentBlockedException: $message (reason: $blockReason)';
}

/// API service unavailable
class ApiServiceUnavailableException extends ApiException {
  ApiServiceUnavailableException({
    super.message = 'Service temporarily unavailable',
    super.userMessage =
        'Service is temporarily unavailable. Please try again later.',
    super.statusCode = 503,
    super.endpoint,
  });
}

/// API invalid response
class ApiInvalidResponseException extends ApiException {
  ApiInvalidResponseException({
    required super.message,
    super.userMessage = 'Received invalid response from server.',
    super.endpoint,
    super.originalError,
  });
}

/// Image processing exceptions
class ImageException extends AppException {
  ImageException({
    required super.message,
    super.userMessage,
    super.originalError,
    super.stackTrace,
  });
}

/// Image picking cancelled by user
class ImagePickCancelledException extends ImageException {
  ImagePickCancelledException()
      : super(
          message: 'User cancelled image selection',
          userMessage: null, // No user message - not really an error
        );
}

/// Image file is empty or corrupted
class ImageInvalidException extends ImageException {
  ImageInvalidException({
    super.message = 'Image file is invalid or empty',
    super.userMessage = 'The selected image is invalid. Please try another one.',
    super.originalError,
  });
}

/// Image saving to gallery failed
class ImageSaveException extends ImageException {
  ImageSaveException({
    required super.message,
    super.userMessage = 'Failed to save image to gallery.',
    super.originalError,
  });
}

/// Storage exceptions (Hive)
class StorageException extends AppException {
  final String? boxName;

  StorageException({
    required super.message,
    super.userMessage = 'Failed to access local storage.',
    this.boxName,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'StorageException: $message (box: $boxName)';
}

/// Network connectivity exception
class NetworkException extends AppException {
  NetworkException({
    super.message = 'Network error',
    super.userMessage = 'No internet connection. Please check your network.',
    super.originalError,
  });
}

/// Permission denied exception
class PermissionDeniedException extends AppException {
  final String permission;

  PermissionDeniedException({
    required this.permission,
    super.message = 'Permission denied',
    String? userMessage,
  }) : super(
          userMessage: userMessage ??
              'Permission denied for $permission. Please enable it in settings.',
        );
}

/// Sound/Audio exception
class AudioException extends AppException {
  AudioException({
    required super.message,
    super.userMessage,
    super.originalError,
  });
}

/// Validation exception
class ValidationException extends AppException {
  final String field;

  ValidationException({
    required this.field,
    required super.message,
    super.userMessage,
  });

  @override
  String toString() => 'ValidationException($field): $message';
}
