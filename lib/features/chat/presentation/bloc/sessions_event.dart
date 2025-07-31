// lib/features/chat/presentation/bloc/sessions_event.dart
part of 'sessions_bloc.dart';

abstract class SessionsEvent extends Equatable {
  const SessionsEvent();
  @override
  List<Object> get props => [];
}

class FetchSessions extends SessionsEvent {
  final bool forceRefresh;
  const FetchSessions({this.forceRefresh = false});

  @override
  List<Object> get props => [forceRefresh];
}

class DeleteAllUserHistoryEvent extends SessionsEvent {}

class DeleteSpecificSessionEvent extends SessionsEvent {
  final String sessionId;
  const DeleteSpecificSessionEvent(this.sessionId);
  @override
  List<Object> get props => [sessionId];
}
