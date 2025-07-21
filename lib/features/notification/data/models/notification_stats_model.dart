import 'package:json_annotation/json_annotation.dart';

part 'notification_stats_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class NotificationStatsModel {
  final int totalNotifications;
  final int unreadCount;

  NotificationStatsModel({
    required this.totalNotifications,
    required this.unreadCount,
  });

  factory NotificationStatsModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationStatsModelFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationStatsModelToJson(this);
}
