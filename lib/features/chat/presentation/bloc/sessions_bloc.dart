// lib/features/chat/presentation/bloc/sessions_bloc.dart
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
    // --- LOGIKA CERDAS DIMULAI DI SINI ---
    // Jika state sudah `SessionsLoaded` dan tidak ada paksaan refresh,
    // maka cukup emit state yang ada (ambil dari cache BLoC).
    if (currentState is SessionsLoaded && !event.forceRefresh) {
      emit(currentState);
      return;
    }
    // ---------------------------------

    // Jika belum ada data atau dipaksa refresh, lanjutkan fetch.
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
      (failure) => emit(SessionsActionFailure(failure.message)),
      (_) {
        emit(const SessionsActionSuccess("Semua riwayat berhasil dihapus."));
        // Setelah hapus, PAKSA refresh untuk mendapatkan list kosong
        add(const FetchSessions(forceRefresh: true));
      },
    );
  }

  Future<void> _onDeleteSpecificSession(
      DeleteSpecificSessionEvent event, Emitter<SessionsState> emit) async {
    final result =
        await _deleteChatSession(SessionIdParams(sessionId: event.sessionId));
    result.fold(
      (failure) => emit(SessionsActionFailure(failure.message)),
      (_) {
        emit(const SessionsActionSuccess("Sesi berhasil dihapus."));
        // Setelah hapus, PAKSA refresh untuk mendapatkan list yang terupdate
        add(const FetchSessions(forceRefresh: true));
      },
    );
  }
}
