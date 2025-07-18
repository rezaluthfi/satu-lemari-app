import 'package:dio/dio.dart';
import 'package:satulemari/features/auth/data/datasources/auth_local_datasource.dart';

class AuthInterceptor extends Interceptor {
  final AuthLocalDataSource authLocalDataSource;

  AuthInterceptor(this.authLocalDataSource);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Interceptor ini HANYA bertanggung jawab untuk menambahkan token.
    // JANGAN mengatur Content-Type di sini.

    final token = await authLocalDataSource.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Lanjutkan request
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    super.onError(err, handler);
  }
}
