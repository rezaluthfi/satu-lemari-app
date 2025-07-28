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

  // ... (semua method lain tetap sama, tidak perlu diubah)

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

  // --- PERBAIKAN ADA DI DALAM METHOD INI ---
  @override
  Future<Either<Failure, AuthResponseModel>> refreshToken() async {
    if (await networkInfo.isConnected) {
      try {
        final newAuthResponse = await remoteDataSource.refreshToken();

        // **PERBAIKAN:** Cek apakah accessToken tidak null sebelum caching
        final newAccessToken = newAuthResponse.data?.accessToken;
        if (newAccessToken != null) {
          await localDataSource
              .cacheNewAccessToken(newAccessToken); // Sekarang aman
          return Right(newAuthResponse);
        } else {
          // Jika backend mengembalikan response sukses tapi tanpa token, itu adalah error
          return Left(ServerFailure(newAuthResponse.message ??
              'Refresh token failed: No access token received.'));
        }
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('No internet connection.'));
    }
  }
}
