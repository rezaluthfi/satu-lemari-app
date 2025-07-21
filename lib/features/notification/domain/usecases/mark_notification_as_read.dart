import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/notification/domain/repositories/notification_repository.dart';

class MarkNotificationAsReadUseCase
    implements UseCase<void, MarkNotificationAsReadParams> {
  final NotificationRepository repository;
  MarkNotificationAsReadUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(
      MarkNotificationAsReadParams params) async {
    return await repository.markAsRead(params.notificationId);
  }
}

class MarkNotificationAsReadParams extends Equatable {
  final String notificationId;
  const MarkNotificationAsReadParams({required this.notificationId});
  @override
  List<Object> get props => [notificationId];
}
