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

  // Helper function to get user-friendly error messages from Firebase error codes
  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Email tidak terdaftar. Silakan periksa email Anda atau daftar akun baru.';
      case 'wrong-password':
        return 'Password salah. Silakan periksa password Anda.';
      case 'invalid-email':
        return 'Format email tidak valid. Silakan masukkan email yang benar.';
      case 'user-disabled':
        return 'Akun Anda telah dinonaktifkan. Hubungi customer service untuk bantuan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan login. Silakan coba lagi dalam beberapa menit.';
      case 'operation-not-allowed':
        return 'Metode login ini tidak diizinkan. Hubungi administrator.';
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan password yang lebih kuat dengan minimal 6 karakter.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silakan login atau gunakan email lain.';
      case 'invalid-credential':
        return 'Email atau password salah. Silakan periksa kembali data Anda.';
      case 'account-exists-with-different-credential':
        return 'Akun dengan email ini sudah ada dengan metode login berbeda.';
      case 'invalid-verification-code':
        return 'Kode verifikasi tidak valid.';
      case 'invalid-verification-id':
        return 'ID verifikasi tidak valid.';
      case 'network-request-failed':
        return 'Gagal terhubung ke internet. Periksa koneksi Anda dan coba lagi.';
      case 'requires-recent-login':
        return 'Operasi ini memerlukan login ulang untuk keamanan.';
      default:
        return 'Terjadi kesalahan saat autentikasi. Silakan coba lagi.';
    }
  }

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
      String errorMessage = 'Terjadi kesalahan pada server. Silakan coba lagi.';

      // Check if backend provides specific error message
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('message')) {
        final backendMessage = responseData['message'] as String;

        // Map common backend error messages to user-friendly Indonesian messages
        if (backendMessage.toLowerCase().contains('invalid') ||
            backendMessage.toLowerCase().contains('unauthorized')) {
          errorMessage =
              'Data login tidak valid. Silakan periksa email dan password Anda.';
        } else if (backendMessage.toLowerCase().contains('expired')) {
          errorMessage = 'Sesi telah berakhir. Silakan login ulang.';
        } else if (backendMessage.toLowerCase().contains('network') ||
            backendMessage.toLowerCase().contains('connection')) {
          errorMessage =
              'Gagal terhubung ke server. Periksa koneksi internet Anda.';
        } else if (backendMessage.toLowerCase().contains('server error') ||
            e.response?.statusCode == 500) {
          errorMessage =
              'Terjadi kesalahan pada server. Silakan coba beberapa saat lagi.';
        } else {
          // Use backend message if it's already in Indonesian or user-friendly
          errorMessage = backendMessage;
        }
      } else {
        // Handle specific HTTP status codes
        switch (e.response?.statusCode) {
          case 400:
            errorMessage =
                'Data yang dikirim tidak valid. Silakan periksa kembali.';
            break;
          case 401:
            errorMessage = 'Email atau password salah. Silakan coba lagi.';
            break;
          case 403:
            errorMessage = 'Akses ditolak. Hubungi administrator.';
            break;
          case 404:
            errorMessage = 'Service tidak ditemukan. Silakan coba lagi.';
            break;
          case 429:
            errorMessage =
                'Terlalu banyak percobaan. Silakan tunggu beberapa menit.';
            break;
          case 500:
            errorMessage =
                'Terjadi kesalahan pada server. Silakan coba beberapa saat lagi.';
            break;
          default:
            if (e.type == DioExceptionType.connectionTimeout ||
                e.type == DioExceptionType.receiveTimeout) {
              errorMessage =
                  'Koneksi timeout. Periksa internet Anda dan coba lagi.';
            } else if (e.type == DioExceptionType.connectionError) {
              errorMessage =
                  'Gagal terhubung ke server. Periksa koneksi internet Anda.';
            }
        }
      }
      throw ServerException(message: errorMessage);
    } catch (e) {
      throw ServerException(
          message: 'Terjadi kesalahan yang tidak terduga. Silakan coba lagi.');
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
      final userFriendlyMessage = _getFirebaseErrorMessage(e.code);
      throw ServerException(message: userFriendlyMessage);
    } catch (e) {
      throw ServerException(
          message: 'Gagal mendaftar akun. Silakan coba lagi.');
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
      final userFriendlyMessage = _getFirebaseErrorMessage(e.code);
      throw ServerException(message: userFriendlyMessage);
    } catch (e) {
      throw ServerException(message: 'Gagal masuk ke akun. Silakan coba lagi.');
    }
  }

  // Login user with Google account
  @override
  Future<AuthResponseModel> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw ServerException(message: "Login dengan Google dibatalkan.");
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
            message: "Gagal mendapatkan token dari Google Sign-In.");
      }

      final backendRequest = AuthRequestModel(token: idToken, type: 'google');

      return await _verifyTokenToBackend(backendRequest);
    } on firebase.FirebaseAuthException catch (e) {
      await googleSignIn.signOut();
      final userFriendlyMessage = _getFirebaseErrorMessage(e.code);
      throw ServerException(message: userFriendlyMessage);
    } catch (e) {
      await googleSignIn.signOut();
      if (e is ServerException) {
        rethrow; // Preserve ServerException with user-friendly message
      }
      throw ServerException(
          message: 'Gagal login dengan Google. Silakan coba lagi.');
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
