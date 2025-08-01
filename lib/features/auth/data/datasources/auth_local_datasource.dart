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
  Future<void> cacheRefreshedAuthResponse(AuthResponseModel newAuthResponse);
  Future<void> updateCachedUserData(Map<String, dynamic> updatedUserData);
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
    print('💾 [LOCAL_DATASOURCE] Caching new access token...');
    final jsonString = sharedPreferences.getString(CACHED_AUTH_RESPONSE);
    if (jsonString != null) {
      final authData = json.decode(jsonString) as Map<String, dynamic>;
      if (authData['data'] is Map) {
        (authData['data'] as Map<String, dynamic>)['access_token'] =
            accessToken;

        await sharedPreferences.setString(
          CACHED_AUTH_RESPONSE,
          json.encode(authData),
        );
        print('✅ [LOCAL_DATASOURCE] Access token berhasil di-cache');
      } else {
        print('❌ [LOCAL_DATASOURCE] Format data auth tidak valid');
        throw CacheException('Invalid auth data format');
      }
    } else {
      print(
          '❌ [LOCAL_DATASOURCE] Tidak ada cached auth response yang ditemukan');
      throw CacheException(
          'Cannot update token, no cached auth response found.');
    }
  }

  /// Method tambahan untuk cache seluruh auth response yang baru
  Future<void> cacheRefreshedAuthResponse(
      AuthResponseModel newAuthResponse) async {
    print('💾 [LOCAL_DATASOURCE] Caching refreshed auth response...');
    final jsonString = sharedPreferences.getString(CACHED_AUTH_RESPONSE);
    if (jsonString != null) {
      final oldAuthData = json.decode(jsonString) as Map<String, dynamic>;
      final newAuthData = newAuthResponse.toJson();

      // Preserve user data dari cache lama jika ada
      if (oldAuthData['data'] is Map && newAuthData['data'] is Map) {
        final oldData = oldAuthData['data'] as Map<String, dynamic>;
        final newData = newAuthData['data'] as Map<String, dynamic>;

        // Preserve user info jika tidak ada di response baru
        if (newData['user'] == null && oldData['user'] != null) {
          newData['user'] = oldData['user'];
        }
      }

      await sharedPreferences.setString(
        CACHED_AUTH_RESPONSE,
        json.encode(newAuthData),
      );
      print('✅ [LOCAL_DATASOURCE] Refreshed auth response berhasil di-cache');
    } else {
      // Jika tidak ada cache lama, cache yang baru
      await cacheAuthResponse(newAuthResponse);
      print(
          '✅ [LOCAL_DATASOURCE] New auth response berhasil di-cache (first time)');
    }
  }

  @override
  Future<void> updateCachedUserData(Map<String, dynamic> updatedUserData) async {
    print('💾 [LOCAL_DATASOURCE] Updating cached user data...');
    final jsonString = sharedPreferences.getString(CACHED_AUTH_RESPONSE);
    if (jsonString != null) {
      final authData = json.decode(jsonString) as Map<String, dynamic>;
      
      // Update user data di dalam auth response
      if (authData['data'] is Map) {
        final data = authData['data'] as Map<String, dynamic>;
        if (data['user'] is Map) {
          final userData = data['user'] as Map<String, dynamic>;
          // Update fields yang berubah
          updatedUserData.forEach((key, value) {
            userData[key] = value;
          });
          
          // Simpan kembali ke cache
          await sharedPreferences.setString(
            CACHED_AUTH_RESPONSE,
            json.encode(authData),
          );
          print('✅ [LOCAL_DATASOURCE] User data berhasil diupdate di cache');
        }
      }
    } else {
      print('❌ [LOCAL_DATASOURCE] Tidak ada cached auth response yang ditemukan');
      throw CacheException('Cannot update user data, no cached auth response found.');
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
