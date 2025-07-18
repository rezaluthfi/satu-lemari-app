import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/profile/domain/entities/profile.dart';
import 'package:satulemari/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase implements UseCase<Profile, NoParams> {
  final ProfileRepository repository;
  GetProfileUseCase(this.repository);

  @override
  Future<Either<Failure, Profile>> call(NoParams params) async {
    return await repository.getProfile();
  }
}
