// File: lib/features/notification/data/datasources/notification_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:satulemari/core/constants/app_urls.dart';
import 'package:satulemari/core/errors/exceptions.dart';
import 'package:satulemari/features/notification/data/models/notification_model.dart';
import 'package:satulemari/features/notification/data/models/notification_stats_model.dart';

abstract class NotificationRemoteDataSource {
  Future<void> registerFCMToken(String token);
  Future<void> deleteFCMToken(String token);
  Future<List<NotificationModel>> getMyNotifications();
  Future<NotificationStatsModel> getNotificationStats();
  Future<void> markAsRead(String notificationId);
  Future<void> markMultipleAsRead(List<String> notificationIds);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
  Future<void> deleteMultipleNotifications(List<String> notificationIds);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio dio;
  NotificationRemoteDataSourceImpl({required this.dio});

  void _handleDioError(DioException e, String defaultMessage) {
    String errorMessage = defaultMessage;
    if (e.response?.data != null && e.response!.data is Map) {
      final errorData = e.response!.data;
      if (errorData['error'] != null && errorData['error'] is Map) {
        errorMessage = errorData['error']['message'] ?? errorMessage;
      } else {
        errorMessage = errorData['message'] ?? errorMessage;
      }
    } else if (e.response?.data != null && e.response!.data is String) {
      errorMessage = e.response!.data;
    }
    throw ServerException(message: errorMessage);
  }

  @override
  Future<void> registerFCMToken(String token) async {
    try {
      await dio.post(AppUrls.fcmToken,
          data: {'token': token, 'platform': 'android'});
    } on DioException catch (e) {
      _handleDioError(e, 'Gagal mendaftarkan notifikasi');
    }
  }

  @override
  Future<void> deleteFCMToken(String token) async {
    try {
      await dio.delete(AppUrls.fcmToken, data: {'token': token});
    } on DioException catch (e) {
      _handleDioError(e, 'Gagal menghapus token notifikasi');
    }
  }

  @override
  Future<List<NotificationModel>> getMyNotifications() async {
    try {
      final response = await dio.get(AppUrls.notifications);
      final List<dynamic> data = response.data['data'];
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } on DioException catch (e) {
      _handleDioError(e, 'Gagal memuat notifikasi');
      throw Exception(
          'Unreachable'); // Ensures function never completes normally
    }
  }

  @override
  Future<NotificationStatsModel> getNotificationStats() async {
    try {
      final response = await dio.get(AppUrls.notificationStats);
      return NotificationStatsModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      _handleDioError(e, 'Gagal memuat statistik notifikasi');
      throw Exception(
          'Unreachable'); // Ensures function never completes normally
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await dio.put('${AppUrls.notifications}/$notificationId/read');
    } on DioException catch (e) {
      _handleDioError(e, 'Gagal menandai notifikasi');
    }
  }

  @override
  Future<void> markMultipleAsRead(List<String> notificationIds) async {
    try {
      await dio.put(AppUrls.markNotificationsRead,
          data: {'notification_ids': notificationIds});
    } on DioException catch (e) {
      _handleDioError(e, 'Gagal menandai notifikasi');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await dio.put(AppUrls.markAllNotificationsRead);
    } on DioException catch (e) {
      _handleDioError(e, 'Gagal menandai semua notifikasi');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await dio.delete('${AppUrls.notifications}/$notificationId');
    } on DioException catch (e) {
      _handleDioError(e, 'Gagal menghapus notifikasi');
    }
  }

  @override
  Future<void> deleteMultipleNotifications(List<String> notificationIds) async {
    try {
      await dio.delete(
        AppUrls.deleteNotificationsBulk,
        data: {'notification_ids': notificationIds},
      );
    } on DioException catch (e) {
      _handleDioError(e, 'Gagal menghapus notifikasi');
    }
  }
}
