import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/notification/domain/entities/notification_stats.dart';
import 'package:satulemari/features/notification/domain/repositories/notification_repository.dart';

class GetNotificationStatsUseCase
    implements UseCase<NotificationStats, NoParams> {
  final NotificationRepository repository;
  GetNotificationStatsUseCase(this.repository);

  @override
  Future<Either<Failure, NotificationStats>> call(NoParams params) async {
    return await repository.getNotificationStats();
  }
}
