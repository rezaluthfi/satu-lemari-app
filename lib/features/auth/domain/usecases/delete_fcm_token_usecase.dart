import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/notification/domain/repositories/notification_repository.dart';

class DeleteFCMTokenUseCase implements UseCase<void, DeleteFCMTokenParams> {
  final NotificationRepository repository;
  DeleteFCMTokenUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteFCMTokenParams params) async {
    return await repository.deleteFCMToken(params.token);
  }
}

class DeleteFCMTokenParams extends Equatable {
  final String token;
  const DeleteFCMTokenParams({required this.token});
  @override
  List<Object> get props => [token];
}
