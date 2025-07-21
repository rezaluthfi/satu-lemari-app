import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/features/notification/domain/entities/notification_entity.dart';
import 'package:satulemari/features/notification/domain/entities/notification_stats.dart';

abstract class NotificationRepository {
  Future<Either<Failure, void>> registerFCMToken(String token);
  Future<Either<Failure, void>> deleteFCMToken(String token);
  Future<Either<Failure, List<NotificationEntity>>> getMyNotifications();
  Future<Either<Failure, NotificationStats>> getNotificationStats();
  Future<Either<Failure, void>> markAsRead(String notificationId);
  Future<Either<Failure, void>> markMultipleAsRead(
      List<String> notificationIds);
  Future<Either<Failure, void>> markAllAsRead();
  Future<Either<Failure, void>> deleteNotification(String notificationId);
  Future<Either<Failure, void>> deleteMultipleNotifications(
      List<String> notificationIds);
}
