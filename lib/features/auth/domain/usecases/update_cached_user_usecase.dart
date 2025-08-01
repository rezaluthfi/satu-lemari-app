import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateCachedUserParams {
  final User user;

  UpdateCachedUserParams({required this.user});
}

class UpdateCachedUserUseCase implements UseCase<void, UpdateCachedUserParams> {
  final AuthRepository repository;

  UpdateCachedUserUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateCachedUserParams params) async {
    return await repository.updateCachedUserData(params.user);
  }
}
