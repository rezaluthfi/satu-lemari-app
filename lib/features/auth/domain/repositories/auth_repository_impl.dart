import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/auth_response.dart';
import '../entities/user.dart';
import 'auth_repository.dart';

// Implementation of authentication repository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  // Helper function to handle authentication logic
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

  // Register user with email
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

  // Login user with email
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

  // Login user with Google
  @override
  Future<Either<Failure, User>> loginWithGoogle() async {
    return _authenticate(() => remoteDataSource.loginWithGoogle());
  }

  // Log out user
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      if (await networkInfo.isConnected) {
        // Panggilan logout ke remoteDataSource opsional, tergantung API Anda
        // await remoteDataSource.logout();
      }
      print("[AUTH_REPO_IMPL_LOG] Memanggil localDataSource.clearCache().");
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear local auth data.'));
    }
  }

  // Retrieve current user from cache
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
}
