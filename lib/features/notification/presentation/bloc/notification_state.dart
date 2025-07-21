part of 'notification_bloc.dart';

enum NotificationStatus { initial, loading, success, error }

class NotificationState extends Equatable {
  final NotificationStatus status;
  final List<NotificationEntity> notifications;
  final NotificationStats? stats;
  final String? errorMessage;
  final bool isSubmitting;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.stats,
    this.errorMessage,
    this.isSubmitting = false,
  });

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationEntity>? notifications,
    NotificationStats? stats,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      stats: stats ?? this.stats,
      // Hapus pesan error lama saat state baru dibuat
      // kecuali jika pesan error baru disediakan
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props =>
      [status, notifications, stats, errorMessage, isSubmitting];
}
