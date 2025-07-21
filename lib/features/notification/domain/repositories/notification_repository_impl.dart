import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/exceptions.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/network/network_info.dart';
import 'package:satulemari/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:satulemari/features/notification/domain/entities/notification_entity.dart';
import 'package:satulemari/features/notification/domain/entities/notification_stats.dart';
import 'package:satulemari/features/notification/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  NotificationRepositoryImpl(
      {required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, void>> registerFCMToken(String token) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.registerFCMToken(token);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFCMToken(String token) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteFCMToken(token);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> getMyNotifications() async {
    if (await networkInfo.isConnected) {
      try {
        final models = await remoteDataSource.getMyNotifications();
        final entities = models
            .map((model) => NotificationEntity(
                  id: model.id,
                  title: model.title,
                  message: model.message,
                  type: model.type,
                  data: model.data,
                  isRead: model.isRead,
                  createdAt: model.createdAt,
                ))
            .toList();
        return Right(entities);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failure, NotificationStats>> getNotificationStats() async {
    if (await networkInfo.isConnected) {
      try {
        final model = await remoteDataSource.getNotificationStats();
        return Right(NotificationStats(
          totalNotifications: model.totalNotifications,
          unreadCount: model.unreadCount,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.markAsRead(notificationId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failure, void>> markMultipleAsRead(
      List<String> notificationIds) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.markMultipleAsRead(notificationIds);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.markAllAsRead();
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(
      String notificationId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteNotification(notificationId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMultipleNotifications(
      List<String> notificationIds) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteMultipleNotifications(notificationIds);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('No Internet Connection'));
    }
  }
}
