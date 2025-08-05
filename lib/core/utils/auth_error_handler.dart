import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Utility class for handling authentication-related errors and user feedback
class AuthErrorHandler {
  /// Shows a snackbar for token refresh errors (non-blocking)
  static void showTokenRefreshError(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange[700],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Shows a snackbar for successful token refresh (optional feedback)
  static void showTokenRefreshSuccess(BuildContext context) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Sesi berhasil diperpanjang',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Logs authentication errors for debugging
  static void logAuthError(String operation, String error) {
    if (kDebugMode) {
      debugPrint('🔐 AUTH_ERROR [$operation]: $error');
    }
  }

  /// Logs authentication success for debugging
  static void logAuthSuccess(String operation) {
    if (kDebugMode) {
      debugPrint(
          '✅ AUTH_SUCCESS [$operation]: Operation completed successfully');
    }
  }

  /// Determines if an error is related to token expiration
  static bool isTokenExpiredError(String errorMessage) {
    final lowerMessage = errorMessage.toLowerCase();
    return lowerMessage.contains('expired') ||
        lowerMessage.contains('invalid') ||
        lowerMessage.contains('unauthorized') ||
        lowerMessage.contains('token') && lowerMessage.contains('invalid');
  }

  /// Determines if an error is a network-related error
  static bool isNetworkError(String errorMessage) {
    final lowerMessage = errorMessage.toLowerCase();
    return lowerMessage.contains('network') ||
        lowerMessage.contains('connection') ||
        lowerMessage.contains('timeout') ||
        lowerMessage.contains('internet');
  }

  /// Gets a user-friendly error message for authentication errors
  static String getUserFriendlyErrorMessage(String originalError) {
    if (isTokenExpiredError(originalError)) {
      return 'Sesi Anda telah berakhir. Silakan login kembali.';
    } else if (isNetworkError(originalError)) {
      return 'Koneksi internet bermasalah. Silakan coba lagi.';
    } else {
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }
}
