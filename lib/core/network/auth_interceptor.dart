import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:satulemari/core/constants/app_urls.dart';
import 'package:satulemari/core/di/injection.dart';
import 'package:satulemari/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:satulemari/features/auth/domain/repositories/auth_repository.dart';

// Pengaturan Simulasi
const bool _ENABLE_SIMULATION = false;
bool _hasSimulatedError = false;

// Flag sederhana untuk mencegah beberapa proses refresh berjalan bersamaan.
bool _isRefreshing = false;

class AuthInterceptor extends QueuedInterceptorsWrapper {
  final AuthLocalDataSource authLocalDataSource;

  AuthInterceptor(this.authLocalDataSource);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final isAuthEndpoint = options.path.startsWith('/auth/');

    // Simulasi error hanya untuk endpoint non-auth
    if (kDebugMode && _ENABLE_SIMULATION && !isAuthEndpoint) {
      if (!_hasSimulatedError) {
        debugPrint('--- 🚨 SIMULASI TOKEN EXPIRED DIAKTIFKAN 🚨 ---');
        _hasSimulatedError = true;
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
          '---  interceptor: Menerima 401 untuk ${err.requestOptions.path} ---');

      // Jika proses refresh sudah berjalan, tolak request ini.
      // QueuedInterceptorsWrapper akan menahannya dan mencoba lagi nanti.
      if (_isRefreshing) {
        debugPrint(
            '---  interceptor: Proses refresh sedang berjalan, menolak sementara request ${err.requestOptions.path} ---');
        return handler.reject(err);
      }

      _isRefreshing = true;
      debugPrint('---  interceptor: Memulai proses refresh token BARU... ---');

      try {
        final authRepository = sl<AuthRepository>();
        final result = await authRepository.refreshToken();

        await result.fold(
          (failure) async {
            debugPrint(
                '--- 😭 interceptor: Refresh token GAGAL. Pesan Failure: ${failure.toString()} ---');
            debugPrint(
                '--- 😭 interceptor: Refresh token GAGAL. Membersihkan cache. ---');
            await authLocalDataSource.clearCache();
            handler.next(err); // Teruskan error asli dari request yang gagal
          },
          (newAuthResponse) async {
            debugPrint('--- 🎉 interceptor: Refresh token SUKSES. ---');
            // Ulangi request yang pertama kali memicu error ini
            await _retryRequest(err, handler);
          },
        );
      } catch (e) {
        debugPrint(
            '--- 😭 interceptor: Terjadi exception saat proses refresh: $e ---');
        handler.next(err); // Teruskan error
      } finally {
        // Apapun hasilnya, proses refresh sudah selesai. Buka kunci.
        _isRefreshing = false;
        debugPrint(
            '---  interceptor: Proses refresh selesai. Flag direset. ---');
      }
    } else {
      super.onError(err, handler);
    }
  }

  Future<void> _retryRequest(
      DioException err, ErrorInterceptorHandler handler) async {
    final dio = sl<Dio>();
    final newAccessToken = await authLocalDataSource.getAccessToken();

    if (newAccessToken != null) {
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newAccessToken';
      debugPrint('---  interceptor: Mengulang request untuk ${opts.path} ---');
      try {
        final response = await dio.fetch(opts);
        handler.resolve(response);
      } on DioException catch (e) {
        handler.next(e);
      }
    } else {
      handler.next(err);
    }
  }
}
