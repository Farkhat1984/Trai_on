import '../../constants/app_constants.dart';

/// Retry policy for API requests
class RetryPolicy {
  int attempts = 0;
  int delay = AppConstants.initialRetryDelayMs;
  final int maxAttempts = AppConstants.maxApiRetryAttempts;

  /// Check if we should retry
  bool shouldRetry() => attempts < maxAttempts;

  /// Increment attempt counter
  void incrementAttempt() {
    attempts++;
  }

  /// Get current delay and double it for next time
  Future<void> waitAndIncreaseDelay() async {
    await Future.delayed(Duration(milliseconds: delay));
    delay *= 2;
  }

  /// Wait with doubled delay (for 503 errors)
  Future<void> waitDoubledDelay() async {
    await Future.delayed(Duration(milliseconds: delay * 2));
    delay *= 2;
  }

  /// Reset the policy
  void reset() {
    attempts = 0;
    delay = AppConstants.initialRetryDelayMs;
  }
}
