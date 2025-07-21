import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/notification/domain/repositories/notification_repository.dart';

class DeleteMultipleNotificationsUseCase
    implements UseCase<void, DeleteMultipleNotificationsParams> {
  final NotificationRepository repository;
  DeleteMultipleNotificationsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(
      DeleteMultipleNotificationsParams params) async {
    return await repository.deleteMultipleNotifications(params.notificationIds);
  }
}

class DeleteMultipleNotificationsParams extends Equatable {
  final List<String> notificationIds;
  const DeleteMultipleNotificationsParams({required this.notificationIds});
  @override
  List<Object> get props => [notificationIds];
}
