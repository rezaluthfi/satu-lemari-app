part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object> get props => [];
}

class FetchNotifications extends NotificationEvent {}

class FetchNotificationStats extends NotificationEvent {}

class MarkAllAsRead extends NotificationEvent {}

class NotificationTapped extends NotificationEvent {
  final NotificationEntity notification;
  const NotificationTapped(this.notification);
  @override
  List<Object> get props => [notification];
}

class DeleteNotification extends NotificationEvent {
  final String notificationId;
  const DeleteNotification(this.notificationId);
  @override
  List<Object> get props => [notificationId];
}

class DeleteMultipleNotifications extends NotificationEvent {
  final List<String> notificationIds;
  const DeleteMultipleNotifications(this.notificationIds);
  @override
  List<Object> get props => [notificationIds];
}

class MarkMultipleAsRead extends NotificationEvent {
  final List<String> notificationIds;
  const MarkMultipleAsRead(this.notificationIds);
  @override
  List<Object> get props => [notificationIds];
}
