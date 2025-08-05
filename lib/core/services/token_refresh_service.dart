// lib/core/services/token_refresh_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:satulemari/core/di/injection.dart';
import 'package:satulemari/core/utils/auth_error_handler.dart';
import 'package:satulemari/features/auth/domain/repositories/auth_repository.dart';
import 'package:satulemari/features/auth/presentation/bloc/auth_bloc.dart';

/// Centralized service to manage token refresh operations
/// Prevents race conditions and manages refresh state globally
class TokenRefreshService {
  static final TokenRefreshService _instance = TokenRefreshService._internal();
  factory TokenRefreshService() => _instance;
  TokenRefreshService._internal();

  bool _isRefreshing = false;
  final List<Completer<bool>> _pendingRequests = [];

  /// Indicates if a token refresh is currently in progress
  bool get isRefreshing => _isRefreshing;

  /// Performs token refresh with race condition protection
  /// Returns true if refresh was successful, false otherwise
  Future<bool> refreshToken() async {
    // If already refreshing, wait for the current refresh to complete
    if (_isRefreshing) {
      debugPrint(
          '[TOKEN_REFRESH_SERVICE] Refresh already in progress, waiting...');
      final completer = Completer<bool>();
      _pendingRequests.add(completer);
      return completer.future;
    }

    _isRefreshing = true;
    debugPrint('[TOKEN_REFRESH_SERVICE] Starting token refresh...');

    try {
      final authRepository = sl<AuthRepository>();
      final result = await authRepository.refreshToken();

      final success = await result.fold(
        (failure) async {
          AuthErrorHandler.logAuthError('TOKEN_REFRESH', failure.message);

          // Check if refresh token is expired
          if (AuthErrorHandler.isTokenExpiredError(failure.message)) {
            debugPrint(
                '[TOKEN_REFRESH_SERVICE] Refresh token expired, triggering logout');
            _triggerForceLogout();
          }

          return false;
        },
        (authResponse) async {
          AuthErrorHandler.logAuthSuccess('TOKEN_REFRESH');
          _triggerTokenRefreshed();
          return true;
        },
      );

      // Notify all pending requests
      _completePendingRequests(success);
      return success;
    } catch (e) {
      debugPrint('[TOKEN_REFRESH_SERVICE] Unexpected error during refresh: $e');
      _completePendingRequests(false);
      return false;
    } finally {
      _isRefreshing = false;
      debugPrint('[TOKEN_REFRESH_SERVICE] Token refresh process completed');
    }
  }

  /// Triggers the TokenRefreshed event in AuthBloc
  void _triggerTokenRefreshed() {
    try {
      final authBloc = sl<AuthBloc>();
      authBloc.add(TokenRefreshed());
      debugPrint('[TOKEN_REFRESH_SERVICE] TokenRefreshed event dispatched');
    } catch (e) {
      debugPrint(
          '[TOKEN_REFRESH_SERVICE] Failed to dispatch TokenRefreshed event: $e');
    }
  }

  /// Triggers the ForceLogoutDueToExpiredToken event in AuthBloc
  void _triggerForceLogout() {
    try {
      final authBloc = sl<AuthBloc>();
      authBloc.add(ForceLogoutDueToExpiredToken());
      debugPrint(
          '[TOKEN_REFRESH_SERVICE] ForceLogoutDueToExpiredToken event dispatched');
    } catch (e) {
      debugPrint(
          '[TOKEN_REFRESH_SERVICE] Failed to dispatch ForceLogoutDueToExpiredToken event: $e');
    }
  }

  /// Completes all pending refresh requests
  void _completePendingRequests(bool success) {
    for (final completer in _pendingRequests) {
      if (!completer.isCompleted) {
        completer.complete(success);
      }
    }
    _pendingRequests.clear();
  }

  /// Resets the service state (useful for testing)
  void reset() {
    _isRefreshing = false;
    _completePendingRequests(false);
  }
}
