import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

// Use case for logging in with email
class LoginWithEmailUseCase implements UseCase<User, LoginParams> {
  final AuthRepository repository;

  LoginWithEmailUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    return await repository.loginWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}

// Parameters for login use case
class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
