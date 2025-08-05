import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:satulemari/core/constants/app_urls.dart';
import 'package:satulemari/core/di/injection.dart';
import 'package:satulemari/core/services/token_refresh_service.dart';
import 'package:satulemari/features/auth/data/datasources/auth_local_datasource.dart';

// Pengaturan Simulasi - Set to true to test token refresh
const bool _ENABLE_SIMULATION = false; // Change to true for testing
int _simulationCounter = 0;

// Remove the global flag as we now use TokenRefreshService

class AuthInterceptor extends QueuedInterceptorsWrapper {
  final AuthLocalDataSource authLocalDataSource;

  AuthInterceptor(this.authLocalDataSource);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final isAuthEndpoint = options.path.startsWith('/auth/');

    // Simulasi error hanya untuk endpoint non-auth yang mengandung 'users/me'
    if (kDebugMode && _ENABLE_SIMULATION && !isAuthEndpoint) {
      if (options.path.contains('/users/me') && _simulationCounter < 3) {
        debugPrint(
            '--- 🚨 SIMULASI TOKEN EXPIRED DIAKTIFKAN untuk ${options.path} (attempt ${_simulationCounter + 1}) 🚨 ---');
        _simulationCounter++;
        final simulatedError = DioException(
          requestOptions: options,
          response: Response(statusCode: 401, requestOptions: options),
        );
        return handler.reject(simulatedError, true);
      }
    }

    // Jangan tambahkan header 'Authorization' ke endpoint refresh
    if (options.path == AppUrls.authRefresh) {
      return handler.next(options);
    }

    final token = await authLocalDataSource.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        err.requestOptions.path != AppUrls.authRefresh) {
      debugPrint(
          '--- 🔒 interceptor: Received 401 for ${err.requestOptions.path} ---');

      final tokenRefreshService = sl<TokenRefreshService>();

      // If refresh is already in progress, wait for it to complete
      if (tokenRefreshService.isRefreshing) {
        debugPrint(
            '--- ⏳ interceptor: Refresh in progress, waiting for ${err.requestOptions.path} ---');
        // Wait for the refresh to complete and then retry
        final refreshSuccess = await tokenRefreshService.refreshToken();
        if (refreshSuccess) {
          await _retryRequest(err, handler);
        } else {
          handler.next(err);
        }
        return;
      }

      debugPrint('--- 🔄 interceptor: Starting token refresh process... ---');

      try {
        final refreshSuccess = await tokenRefreshService.refreshToken();

        if (refreshSuccess) {
          debugPrint(
              '--- 🎉 interceptor: Token refresh successful, retrying request ---');
          await _retryRequest(err, handler);
        } else {
          debugPrint(
              '--- 😭 interceptor: Token refresh failed, forwarding error ---');
          handler.next(err);
        }
      } catch (e) {
        debugPrint(
            '--- 💥 interceptor: Exception during refresh process: $e ---');
        handler.next(err);
      }
    } else {
      super.onError(err, handler);
    }
  }

  Future<void> _retryRequest(
      DioException err, ErrorInterceptorHandler handler) async {
    try {
      final dio = sl<Dio>();
      final newAccessToken = await authLocalDataSource.getAccessToken();

      if (newAccessToken != null) {
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newAccessToken';
        debugPrint('--- 🔄 interceptor: Retrying request for ${opts.path} ---');

        final response = await dio.fetch(opts);
        handler.resolve(response);
      } else {
        debugPrint(
            '--- ❌ interceptor: No access token available for retry ---');
        handler.next(err);
      }
    } on DioException catch (e) {
      debugPrint(
          '--- ⚠️ interceptor: Retry failed with DioException: ${e.message} ---');
      handler.next(e);
    } catch (e) {
      debugPrint(
          '--- 💥 interceptor: Retry failed with unexpected error: $e ---');
      handler.next(err);
    }
  }
}
