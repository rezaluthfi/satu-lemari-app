import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/chat/domain/entities/chat_session.dart';
import 'package:satulemari/features/chat/domain/usecases/delete_all_message_in_session.dart';
import 'package:satulemari/features/chat/domain/usecases/delete_all_user_history.dart';
import 'package:satulemari/features/chat/domain/usecases/delete_chat_session.dart';
import 'package:satulemari/features/chat/domain/usecases/get_user_sessions.dart';

part 'sessions_event.dart';
part 'sessions_state.dart';

class SessionsBloc extends Bloc<SessionsEvent, SessionsState> {
  final GetUserSessions _getUserSessions;
  final DeleteAllUserHistory _deleteAllUserHistory;
  final DeleteChatSession _deleteChatSession;

  SessionsBloc({
    required GetUserSessions getUserSessions,
    required DeleteAllUserHistory deleteAllUserHistory,
    required DeleteChatSession deleteChatSession,
  })  : _getUserSessions = getUserSessions,
        _deleteAllUserHistory = deleteAllUserHistory,
        _deleteChatSession = deleteChatSession,
        super(SessionsInitial()) {
    on<FetchSessions>(_onFetchSessions);
    on<DeleteAllUserHistoryEvent>(_onDeleteAllUserHistory);
    on<DeleteSpecificSessionEvent>(_onDeleteSpecificSession);
  }

  Future<void> _onFetchSessions(
      FetchSessions event, Emitter<SessionsState> emit) async {
    final currentState = state;
    if (currentState is SessionsLoaded && !event.forceRefresh) {
      // Jika state sebelumnya memiliki pesan, bersihkan saat fetch baru
      emit(currentState.copyWith(clearMessages: true));
      return;
    }

    emit(SessionsLoading());
    final result = await _getUserSessions(const GetUserSessionsParams());
    result.fold(
      (failure) => emit(SessionsError(failure.message)),
      (sessions) => emit(SessionsLoaded(sessions)),
    );
  }

  Future<void> _onDeleteAllUserHistory(
      DeleteAllUserHistoryEvent event, Emitter<SessionsState> emit) async {
    final result = await _deleteAllUserHistory(NoParams());
    result.fold(
      (failure) => emit(SessionsLoaded([],
          failureMessage: failure.message)), // Kirim pesan error
      (_) {
        emit(const SessionsLoaded([],
            successMessage:
                "Semua riwayat berhasil dihapus.")); // Kirim pesan sukses
        add(const FetchSessions(forceRefresh: true));
      },
    );
  }

  Future<void> _onDeleteSpecificSession(
      DeleteSpecificSessionEvent event, Emitter<SessionsState> emit) async {
    final currentState = state;
    if (currentState is! SessionsLoaded) return;

    final List<ChatSession> originalList = List.from(currentState.sessions);
    late ChatSession sessionToDelete;
    try {
      sessionToDelete = originalList.firstWhere((s) => s.id == event.sessionId);
    } catch (e) {
      return;
    }
    final int originalIndex = originalList.indexOf(sessionToDelete);

    final List<ChatSession> optimisticList = List.from(originalList)
      ..remove(sessionToDelete);

    // Emit state optimis, tapi bersihkan pesan sebelumnya
    emit(currentState.copyWith(sessions: optimisticList, clearMessages: true));

    final result =
        await _deleteChatSession(SessionIdParams(sessionId: event.sessionId));

    final lastState = state;
    if (lastState is! SessionsLoaded) return;

    result.fold(
      (failure) {
        // Gagal, kembalikan list dan tambahkan pesan error
        final List<ChatSession> rolledBackList = List.from(lastState.sessions)
          ..insert(originalIndex, sessionToDelete);

        emit(lastState.copyWith(
          sessions: rolledBackList,
          failureMessage: "Gagal menghapus sesi: ${failure.message}",
        ));
      },
      (_) {
        // Sukses, state UI sudah benar, cukup tambahkan pesan sukses
        emit(lastState.copyWith(
          successMessage: "Sesi berhasil dihapus.",
        ));
      },
    );
  }
}
