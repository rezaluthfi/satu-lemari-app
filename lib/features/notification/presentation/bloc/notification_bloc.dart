import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/notification/domain/entities/notification_entity.dart';
import 'package:satulemari/features/notification/domain/entities/notification_stats.dart';
import 'package:satulemari/features/notification/domain/usecases/delete_multiple_notification_usecase.dart';
import 'package:satulemari/features/notification/domain/usecases/delete_notification_usecase.dart';
import 'package:satulemari/features/notification/domain/usecases/get_my_notifications_usecase.dart';
import 'package:satulemari/features/notification/domain/usecases/get_notification_stats_usecase.dart';
import 'package:satulemari/features/notification/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import 'package:satulemari/features/notification/domain/usecases/mark_multiple_notifications_as_read_usecase.dart';
import 'package:satulemari/features/notification/domain/usecases/mark_notification_as_read.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetMyNotificationsUseCase getMyNotifications;
  final GetNotificationStatsUseCase getNotificationStats;
  final MarkAllNotificationsAsReadUseCase markAllAsRead;
  final MarkNotificationAsReadUseCase markAsRead;
  final DeleteNotificationUseCase deleteNotification;
  final DeleteMultipleNotificationsUseCase deleteMultipleNotifications;
  final MarkMultipleNotificationsAsReadUseCase markMultipleAsRead;

  NotificationBloc({
    required this.getMyNotifications,
    required this.getNotificationStats,
    required this.markAllAsRead,
    required this.markAsRead,
    required this.deleteNotification,
    required this.deleteMultipleNotifications,
    required this.markMultipleAsRead,
  }) : super(const NotificationState()) {
    on<FetchNotifications>(_onFetchNotifications);
    on<FetchNotificationStats>(_onFetchNotificationStats);
    on<MarkAllAsRead>(_onMarkAllAsRead);
    on<NotificationTapped>(_onNotificationTapped);
    on<DeleteNotification>(_onDeleteNotification);
    on<DeleteMultipleNotifications>(_onDeleteMultipleNotifications);
    on<MarkMultipleAsRead>(_onMarkMultipleAsRead);
    // --- TAMBAHKAN HANDLER INI ---
    on<NotificationReset>(_onNotificationReset);
  }

  // --- TAMBAHKAN METHOD INI ---
  void _onNotificationReset(
      NotificationReset event, Emitter<NotificationState> emit) {
    print('NotificationBloc state has been reset.');
    emit(const NotificationState());
  }

  Future<void> _onFetchNotifications(
      FetchNotifications event, Emitter<NotificationState> emit) async {
    if (state.notifications.isEmpty) {
      emit(state.copyWith(
          status: NotificationStatus.loading, errorMessage: null));
    }
    final result = await getMyNotifications(NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
          status: NotificationStatus.error, errorMessage: failure.message)),
      (notifications) => emit(state.copyWith(
          status: NotificationStatus.success, notifications: notifications)),
    );
  }

  Future<void> _onFetchNotificationStats(
      FetchNotificationStats event, Emitter<NotificationState> emit) async {
    final result = await getNotificationStats(NoParams());
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (stats) => emit(state.copyWith(stats: stats, errorMessage: null)),
    );
  }

  Future<void> _onMarkAllAsRead(
      MarkAllAsRead event, Emitter<NotificationState> emit) async {
    final originalList = state.notifications;
    final updatedList =
        originalList.map((n) => n.copyWith(isRead: true)).toList();

    // Optimistic Update: Emit list baru & status loading SEBELUM await
    emit(state.copyWith(notifications: updatedList, isSubmitting: true));

    final result = await markAllAsRead(NoParams());

    result.fold(
      (failure) {
        // Jika gagal, kembalikan ke state semula
        emit(state.copyWith(
          notifications: originalList,
          isSubmitting: false,
          errorMessage: failure.message,
        ));
      },
      (_) {
        // Jika sukses, hanya hentikan loading. UI sudah benar.
        emit(state.copyWith(isSubmitting: false));
        add(FetchNotificationStats());
      },
    );
  }

  Future<void> _onNotificationTapped(
      NotificationTapped event, Emitter<NotificationState> emit) async {
    if (!event.notification.isRead) {
      final originalList = state.notifications;
      final updatedList = state.notifications.map((n) {
        if (n.id == event.notification.id) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
      emit(state.copyWith(notifications: updatedList));

      final result = await markAsRead(
          MarkNotificationAsReadParams(notificationId: event.notification.id));

      result.fold(
        (failure) {
          emit(state.copyWith(
            notifications: originalList,
            errorMessage: failure.message,
          ));
        },
        (_) {
          add(FetchNotificationStats());
        },
      );
    }
  }

  Future<void> _onDeleteNotification(
      DeleteNotification event, Emitter<NotificationState> emit) async {
    final originalList = state.notifications;
    final updatedList = List<NotificationEntity>.from(originalList)
      ..removeWhere((n) => n.id == event.notificationId);

    // Optimistic Update: Emit list baru & status loading SEBELUM await
    emit(state.copyWith(notifications: updatedList, isSubmitting: true));

    final result = await deleteNotification(
        DeleteNotificationParams(notificationId: event.notificationId));

    result.fold(
      (failure) {
        emit(state.copyWith(
          notifications: originalList,
          isSubmitting: false,
          errorMessage: failure.message,
        ));
      },
      (_) {
        emit(state.copyWith(isSubmitting: false));
        add(FetchNotificationStats());
      },
    );
  }

  Future<void> _onDeleteMultipleNotifications(DeleteMultipleNotifications event,
      Emitter<NotificationState> emit) async {
    final originalList = state.notifications;
    final updatedList = List<NotificationEntity>.from(originalList)
      ..removeWhere((n) => event.notificationIds.contains(n.id));

    // Optimistic Update: Emit list baru & status loading SEBELUM await
    emit(state.copyWith(notifications: updatedList, isSubmitting: true));

    final result = await deleteMultipleNotifications(
        DeleteMultipleNotificationsParams(
            notificationIds: event.notificationIds));

    result.fold(
      (failure) {
        emit(state.copyWith(
          notifications: originalList,
          isSubmitting: false,
          errorMessage: failure.message,
        ));
      },
      (_) {
        emit(state.copyWith(isSubmitting: false));
        add(FetchNotificationStats());
      },
    );
  }

  Future<void> _onMarkMultipleAsRead(
      MarkMultipleAsRead event, Emitter<NotificationState> emit) async {
    final originalList = state.notifications;
    final updatedList = originalList.map((n) {
      if (event.notificationIds.contains(n.id)) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    // Optimistic Update: Emit list baru & status loading SEBELUM await
    emit(state.copyWith(notifications: updatedList, isSubmitting: true));

    final result = await markMultipleAsRead(
        MarkMultipleNotificationsAsReadParams(
            notificationIds: event.notificationIds));

    result.fold(
      (failure) {
        emit(state.copyWith(
          notifications: originalList,
          isSubmitting: false,
          errorMessage: failure.message,
        ));
      },
      (_) {
        emit(state.copyWith(isSubmitting: false));
        add(FetchNotificationStats());
      },
    );
  }
}
