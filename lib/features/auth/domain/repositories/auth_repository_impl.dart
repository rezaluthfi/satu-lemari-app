import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/auth_response.dart';
import '../entities/user.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  Future<Either<Failure, User>> _authenticate(
    Future<AuthResponseModel> Function() getAuthResponse,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final authResponse = await getAuthResponse();

        if (authResponse.success &&
            authResponse.data != null &&
            authResponse.data!.accessToken != null) {
          await localDataSource.cacheAuthResponse(authResponse);
          return Right(authResponse.data!.user);
        } else {
          return Left(ServerFailure(authResponse.message ??
              'Authentication failed: Invalid server response.'));
        }
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('No internet connection.'));
    }
  }

  @override
  Future<Either<Failure, User>> registerWithEmail({
    required String username,
    required String email,
    required String password,
  }) async {
    return _authenticate(() => remoteDataSource.registerWithEmail(
          username: username,
          email: email,
          password: password,
        ));
  }

  @override
  Future<Either<Failure, User>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return _authenticate(() => remoteDataSource.loginWithEmail(
          email: email,
          password: password,
        ));
  }

  @override
  Future<Either<Failure, User>> loginWithGoogle() async {
    return _authenticate(() => remoteDataSource.loginWithGoogle());
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.logout();
      }
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear local auth data.'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final authResponse = await localDataSource.getLastAuthResponse();

      if (authResponse.data != null && authResponse.data!.accessToken != null) {
        return Right(authResponse.data!.user);
      } else {
        return Left(CacheFailure('Invalid cached data.'));
      }
    } on CacheException {
      return Left(CacheFailure('User is not logged in.'));
    }
  }

  @override
  Future<Either<Failure, AuthResponseModel>> refreshToken() async {
    print('🔄 [AUTH_REPOSITORY] Memulai proses refresh token...');

    if (await networkInfo.isConnected) {
      try {
        final newAuthResponse = await remoteDataSource.refreshToken();
        print('✅ [AUTH_REPOSITORY] Remote refresh token berhasil');

        // Cek apakah accessToken tidak null sebelum caching
        final newAccessToken = newAuthResponse.data?.accessToken;
        if (newAccessToken != null) {
          // Gunakan method caching yang lebih robust
          await localDataSource.cacheRefreshedAuthResponse(newAuthResponse);
          print('✅ [AUTH_REPOSITORY] Auth response berhasil di-cache');

          return Right(newAuthResponse);
        } else {
          // Jika backend mengembalikan response sukses tapi tanpa token, itu adalah error
          print('❌ [AUTH_REPOSITORY] Response tidak mengandung access token');
          return Left(ServerFailure(newAuthResponse.message ??
              'Refresh token failed: No access token received.'));
        }
      } on ServerException catch (e) {
        print('❌ [AUTH_REPOSITORY] Server exception: ${e.message}');

        // Jika refresh token expired, clear cache
        if (e.message.contains('expired') || e.message.contains('invalid')) {
          print(
              '🗑️ [AUTH_REPOSITORY] Clearing cache karena refresh token expired');
          await localDataSource.clearCache();
        }

        return Left(ServerFailure(e.message));
      }
    } else {
      print('❌ [AUTH_REPOSITORY] Tidak ada koneksi internet');
      return Left(ConnectionFailure('No internet connection.'));
    }
  }

  @override
  Future<Either<Failure, void>> updateCachedUserData(User updatedUser) async {
    try {
      // Convert User entity to Map for local storage
      final userMap = {
        'id': updatedUser.id,
        'username': updatedUser.username,
        'full_name': updatedUser.fullName,
        'phone': updatedUser.phone,
        'address': updatedUser.address,
        'city': updatedUser.city,
        'photo': updatedUser.photo,
        'description': updatedUser.description,
        'role': updatedUser.role,
        'created_at': updatedUser.createdAt,
      };

      await localDataSource.updateCachedUserData(userMap);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to update cached user data: $e'));
    }
  }
}
