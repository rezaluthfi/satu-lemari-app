import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginWithGoogleUseCase implements UseCase<User, NoParams> {
  final AuthRepository repository;

  LoginWithGoogleUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await repository.loginWithGoogle();
  }
}
