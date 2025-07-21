import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/notification/domain/repositories/notification_repository.dart';

class MarkMultipleNotificationsAsReadUseCase
    implements UseCase<void, MarkMultipleNotificationsAsReadParams> {
  final NotificationRepository repository;
  MarkMultipleNotificationsAsReadUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(
      MarkMultipleNotificationsAsReadParams params) async {
    return await repository.markMultipleAsRead(params.notificationIds);
  }
}

class MarkMultipleNotificationsAsReadParams extends Equatable {
  final List<String> notificationIds;
  const MarkMultipleNotificationsAsReadParams({required this.notificationIds});
  @override
  List<Object> get props => [notificationIds];
}
