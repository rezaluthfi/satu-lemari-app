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
      // Dio will automatically prepend the baseUrl configured in injection.dart.
      final response = await dio.post(
        AppUrls.authVerify, // This is now a relative path like '/auth/verify'
        data: request.toJson(),
      );

      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ??
          e.message ??
          'An unknown error occurred';
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
}
