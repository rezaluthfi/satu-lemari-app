// lib/features/chat/presentation/bloc/chat_event.dart
part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class InitializeChat extends ChatEvent {
  final String? existingSessionId;
  const InitializeChat({this.existingSessionId});
  @override
  List<Object?> get props => [existingSessionId];
}

class SendTextMessage extends ChatEvent {
  final String text;
  const SendTextMessage(this.text);
  @override
  List<Object> get props => [text];
}

class QuickReplyTapped extends ChatEvent {
  final QuickReply reply;
  const QuickReplyTapped(this.reply);
  @override
  List<Object> get props => [reply];
}

class DeleteSelectedMessagesEvent extends ChatEvent {
  final List<String> messageIds;
  const DeleteSelectedMessagesEvent(this.messageIds);
  @override
  List<Object> get props => [messageIds];
}

class ClearSessionMessages extends ChatEvent {}
