import 'package:equatable/equatable.dart';

class NotificationStats extends Equatable {
  final int totalNotifications;
  final int unreadCount;

  const NotificationStats({
    required this.totalNotifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [totalNotifications, unreadCount];
}
