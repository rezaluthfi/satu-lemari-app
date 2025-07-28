import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/auth_response.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheAuthResponse(AuthResponseModel authResponse);
  Future<AuthResponseModel> getLastAuthResponse();
  Future<void> clearCache();
  Future<String?> getAccessToken();
  Future<void> cacheNewAccessToken(String accessToken);
  Future<void> setOnboardingCompleted();
  Future<bool> hasSeenOnboarding();
}

const CACHED_AUTH_RESPONSE = 'CACHED_AUTH_RESPONSE';
const HAS_SEEN_ONBOARDING = 'HAS_SEEN_ONBOARDING';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheAuthResponse(AuthResponseModel authResponse) {
    return sharedPreferences.setString(
      CACHED_AUTH_RESPONSE,
      json.encode(authResponse.toJson()),
    );
  }

  @override
  Future<AuthResponseModel> getLastAuthResponse() {
    final jsonString = sharedPreferences.getString(CACHED_AUTH_RESPONSE);
    if (jsonString != null) {
      return Future.value(AuthResponseModel.fromJson(json.decode(jsonString)));
    } else {
      throw CacheException('No cached auth response found');
    }
  }

  @override
  Future<void> clearCache() {
    return sharedPreferences.remove(CACHED_AUTH_RESPONSE);
  }

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
  Future<void> cacheNewAccessToken(String accessToken) async {
    final jsonString = sharedPreferences.getString(CACHED_AUTH_RESPONSE);
    if (jsonString != null) {
      final authData = json.decode(jsonString) as Map<String, dynamic>;
      if (authData['data'] is Map) {
        (authData['data'] as Map<String, dynamic>)['access_token'] =
            accessToken;
      }
      await sharedPreferences.setString(
        CACHED_AUTH_RESPONSE,
        json.encode(authData),
      );
    } else {
      throw CacheException(
          'Cannot update token, no cached auth response found.');
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
