import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/profile/domain/repositories/profile_repository.dart';

class DeleteAccountUseCase implements UseCase<void, NoParams> {
  final ProfileRepository repository;
  DeleteAccountUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.deleteAccount();
  }
}
