import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/auth_response.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheAuthResponse(AuthResponseModel authResponse);
  Future<AuthResponseModel> getLastAuthResponse();
  Future<void> clearCache();
  Future<String?> getAccessToken();

  Future<void> setOnboardingCompleted();
  Future<bool> hasSeenOnboarding();
}

const CACHED_AUTH_RESPONSE = 'CACHED_AUTH_RESPONSE';
const HAS_SEEN_ONBOARDING = 'HAS_SEEN_ONBOARDING';

// Implementation of local data source for authentication
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  // Cache authentication response as JSON string
  @override
  Future<void> cacheAuthResponse(AuthResponseModel authResponse) {
    return sharedPreferences.setString(
      CACHED_AUTH_RESPONSE,
      json.encode(authResponse.toJson()),
    );
  }

  // Retrieve cached authentication response
  @override
  Future<AuthResponseModel> getLastAuthResponse() {
    final jsonString = sharedPreferences.getString(CACHED_AUTH_RESPONSE);
    if (jsonString != null) {
      return Future.value(AuthResponseModel.fromJson(json.decode(jsonString)));
    } else {
      throw CacheException('No cached auth response found');
    }
  }

  // Clear cached authentication data
  @override
  Future<void> clearCache() {
    return sharedPreferences.remove(CACHED_AUTH_RESPONSE);
  }

  // Get access token from cached response
  @override
  Future<String?> getAccessToken() async {
    try {
      final authResponse = await getLastAuthResponse();
      return authResponse.data?.accessToken;
    } on CacheException {
      return null;
    }
  }

  @override
  Future<bool> hasSeenOnboarding() async {
    return sharedPreferences.getBool(HAS_SEEN_ONBOARDING) ?? false;
  }

  @override
  Future<void> setOnboardingCompleted() async {
    await sharedPreferences.setBool(HAS_SEEN_ONBOARDING, true);
  }
}
