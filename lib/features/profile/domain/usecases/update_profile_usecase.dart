import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/profile/data/models/update_profile_request.dart';
import 'package:satulemari/features/profile/domain/entities/profile.dart';
import 'package:satulemari/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileUseCase implements UseCase<Profile, UpdateProfileParams> {
  final ProfileRepository repository;
  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, Profile>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(params.request);
  }
}

class UpdateProfileParams extends Equatable {
  final UpdateProfileRequest request;
  const UpdateProfileParams({required this.request});
  @override
  List<Object> get props => [request];
}
