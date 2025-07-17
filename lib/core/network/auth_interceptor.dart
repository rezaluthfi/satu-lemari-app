import 'package:dio/dio.dart';
import 'package:satulemari/features/auth/data/datasources/auth_local_datasource.dart';

class AuthInterceptor extends Interceptor {
  final AuthLocalDataSource authLocalDataSource;

  AuthInterceptor(this.authLocalDataSource);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Dapatkan token untuk setiap request
    final token = await authLocalDataSource.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Lanjutkan request
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Anda bisa menambahkan logika refresh token di sini jika nanti dibutuhkan
    // Contoh: jika error 401, coba refresh token, lalu retry request.
    super.onError(err, handler);
  }
}
