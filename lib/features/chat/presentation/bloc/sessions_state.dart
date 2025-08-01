// lib/features/chat/presentation/bloc/sessions_state.dart
part of 'sessions_bloc.dart';

abstract class SessionsState extends Equatable {
  const SessionsState();
  @override
  List<Object?> get props => [];
}

class SessionsInitial extends SessionsState {}

class SessionsLoading extends SessionsState {}

class SessionsLoaded extends SessionsState {
  final List<ChatSession> sessions;
  final String? successMessage;
  final String? failureMessage;

  const SessionsLoaded(
    this.sessions, {
    this.successMessage,
    this.failureMessage,
  });

  @override
  List<Object?> get props => [sessions, successMessage, failureMessage];

  SessionsLoaded copyWith({
    List<ChatSession>? sessions,
    String? successMessage,
    String? failureMessage,
    bool clearMessages = false, // Flag untuk membersihkan pesan
  }) {
    return SessionsLoaded(
      sessions ?? this.sessions,
      successMessage:
          clearMessages ? null : successMessage ?? this.successMessage,
      failureMessage:
          clearMessages ? null : failureMessage ?? this.failureMessage,
    );
  }
}
// ------------------------------

class SessionsError extends SessionsState {
  final String message;
  const SessionsError(this.message);
  @override
  List<Object> get props => [message];
}
