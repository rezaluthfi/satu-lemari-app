import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/notification/domain/entities/notification_entity.dart';
import 'package:satulemari/features/notification/domain/repositories/notification_repository.dart';

class GetMyNotificationsUseCase
    implements UseCase<List<NotificationEntity>, NoParams> {
  final NotificationRepository repository;
  GetMyNotificationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<NotificationEntity>>> call(
      NoParams params) async {
    return await repository.getMyNotifications();
  }
}
