import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/auth_request.dart';
import '../models/auth_response.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> registerWithEmail({
    required String username,
    required String email,
    required String password,
  });

  Future<AuthResponseModel> loginWithEmail({
    required String email,
    required String password,
  });

  Future<AuthResponseModel> loginWithGoogle();

  Future<void> logout();

  Future<AuthResponseModel> refreshToken();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final firebase.FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.dio,
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  // Helper function to verify token with backend
  Future<AuthResponseModel> _verifyTokenToBackend(
      AuthRequestModel request) async {
    try {
      final response = await dio.post(
        AppUrls.authVerify,
        data: request.toJson(),
      );
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String errorMessage = 'An unknown error occurred';
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('message')) {
        errorMessage = responseData['message'];
      } else {
        errorMessage = e.message ?? errorMessage;
      }
      throw ServerException(message: errorMessage);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // Register user with email and password
  @override
  Future<AuthResponseModel> registerWithEmail({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        throw ServerException(
            message: "Could not retrieve Firebase token after registration.");
      }

      final backendRequest = AuthRequestModel(
        token: idToken,
        type: 'firebase',
        username: username,
      );

      return await _verifyTokenToBackend(backendRequest);
    } on firebase.FirebaseAuthException catch (e) {
      throw ServerException(
          message: e.message ?? 'Firebase registration failed.');
    }
  }

  // Login user with email and password
  @override
  Future<AuthResponseModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        throw ServerException(
            message: "Could not retrieve Firebase token after login.");
      }

      final backendRequest = AuthRequestModel(token: idToken, type: 'firebase');

      return await _verifyTokenToBackend(backendRequest);
    } on firebase.FirebaseAuthException catch (e) {
      throw ServerException(message: e.message ?? 'Firebase login failed.');
    }
  }

  // Login user with Google account
  @override
  Future<AuthResponseModel> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw ServerException(message: "Google Sign-In was cancelled by user.");
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = firebase.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await firebaseAuth.signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        throw ServerException(
            message: "Could not retrieve Firebase token from Google Sign-In.");
      }

      final backendRequest = AuthRequestModel(token: idToken, type: 'google');

      return await _verifyTokenToBackend(backendRequest);
    } catch (e) {
      await googleSignIn.signOut();
      throw ServerException(message: e.toString());
    }
  }

  // Log out user from Firebase and Google
  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();
  }

  @override
  Future<AuthResponseModel> refreshToken() async {
    print('🔄 [REMOTE_DATASOURCE] Memulai method refreshToken...');
    try {
      // Gunakan instance `dio` yang sudah di-inject. CookieManager akan bekerja otomatis.
      print(
          '🚀 [REMOTE_DATASOURCE] Mengirim request POST ke: ${AppUrls.authRefresh}');

      final response = await dio.post(
        AppUrls.authRefresh,
        data: {}, // Body kosong sesuai Postman
        options: Options(
          sendTimeout: const Duration(seconds: 30), // Timeout untuk send
          receiveTimeout: const Duration(seconds: 30), // Timeout untuk receive
        ),
      );

      print(
          '✅ [REMOTE_DATASOURCE] Request SUKSES dengan status: ${response.statusCode}');
      print('📝 [REMOTE_DATASOURCE] Data response mentah: ${response.data}');

      final authResponse = AuthResponseModel.fromJson(response.data);

      // Validasi bahwa response mengandung access token
      if (authResponse.data?.accessToken == null) {
        print(
            '❌ [REMOTE_DATASOURCE] Response tidak mengandung access token yang valid!');
        throw ServerException(
            message: 'Refresh token response tidak mengandung access token');
      }

      print(
          '✅ [REMOTE_DATASOURCE] Refresh token berhasil, access token diperoleh');
      return authResponse;
    } on DioException catch (e) {
      print('❌ [REMOTE_DATASOURCE] Terjadi DioException saat refresh token!');
      print('   - Status Code: ${e.response?.statusCode}');
      print('   - Response Data: ${e.response?.data}');
      print('   - Request Path: ${e.requestOptions.path}');
      print('   - Error Type: ${e.type}');

      // Jika 401 atau 403, kemungkinan refresh token expired
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        print(
            '💀 [REMOTE_DATASOURCE] Refresh token kemungkinan expired (${e.response?.statusCode})');
        throw ServerException(
            message: 'Refresh token expired, silakan login ulang');
      }

      // Jika timeout
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        print('⏰ [REMOTE_DATASOURCE] Refresh token timeout');
        throw ServerException(message: 'Request timeout, silakan coba lagi');
      }

      final errorMessage =
          e.response?.data['message'] ?? e.message ?? 'Token refresh failed';
      throw ServerException(message: errorMessage);
    } catch (e) {
      print('💥 [REMOTE_DATASOURCE] Terjadi Exception umum: $e');
      throw ServerException(message: e.toString());
    }
  }
}
