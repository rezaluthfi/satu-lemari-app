import 'package:dartz/dartz.dart';
import 'package:satulemari/features/auth/domain/entities/user.dart';
import '../../../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> registerWithEmail({
    required String username,
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> loginWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> loginWithGoogle();

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, User>> getCurrentUser();
}
