import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/notification/domain/repositories/notification_repository.dart';

class DeleteNotificationUseCase
    implements UseCase<void, DeleteNotificationParams> {
  final NotificationRepository repository;
  DeleteNotificationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteNotificationParams params) async {
    return await repository.deleteNotification(params.notificationId);
  }
}

class DeleteNotificationParams extends Equatable {
  final String notificationId;
  const DeleteNotificationParams({required this.notificationId});
  @override
  List<Object> get props => [notificationId];
}
