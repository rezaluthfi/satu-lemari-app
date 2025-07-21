// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationStatsModel _$NotificationStatsModelFromJson(
        Map<String, dynamic> json) =>
    NotificationStatsModel(
      totalNotifications: (json['total_notifications'] as num).toInt(),
      unreadCount: (json['unread_count'] as num).toInt(),
    );

Map<String, dynamic> _$NotificationStatsModelToJson(
        NotificationStatsModel instance) =>
    <String, dynamic>{
      'total_notifications': instance.totalNotifications,
      'unread_count': instance.unreadCount,
    };
