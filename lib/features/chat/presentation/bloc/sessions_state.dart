// lib/features/chat/presentation/bloc/sessions_state.dart
part of 'sessions_bloc.dart';

abstract class SessionsState extends Equatable {
  const SessionsState();
  @override
  List<Object> get props => [];
}

class SessionsInitial extends SessionsState {}

class SessionsLoading extends SessionsState {}

class SessionsLoaded extends SessionsState {
  final List<ChatSession> sessions;
  const SessionsLoaded(this.sessions);
  @override
  List<Object> get props => [sessions];
}

class SessionsError extends SessionsState {
  final String message;
  const SessionsError(this.message);
  @override
  List<Object> get props => [message];
}

// State untuk memberikan feedback sementara (misal: SnackBar) tanpa mengubah UI utama
class SessionsActionSuccess extends SessionsState {
  final String message;
  const SessionsActionSuccess(this.message);
}

class SessionsActionFailure extends SessionsState {
  final String message;
  const SessionsActionFailure(this.message);
}
