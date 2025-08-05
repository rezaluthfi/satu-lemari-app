part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final String sessionId;
  final List<ChatMessage> messages;
  final List<QuickReply> quickReplies;
  final List<ChatSuggestion> suggestions;
  final bool isBotTyping;
  final String? successMessage;

  const ChatLoaded({
    required this.sessionId,
    this.messages = const [],
    this.quickReplies = const [],
    this.suggestions = const [],
    this.isBotTyping = false,
    this.successMessage,
  });

  ChatLoaded copyWith({
    String? sessionId,
    List<ChatMessage>? messages,
    List<QuickReply>? quickReplies,
    List<ChatSuggestion>? suggestions,
    bool? isBotTyping,
    String? successMessage,
    bool clearSuccessMessage = false,
  }) {
    return ChatLoaded(
      sessionId: sessionId ?? this.sessionId,
      messages: messages ?? this.messages,
      quickReplies: quickReplies ?? this.quickReplies,
      suggestions: suggestions ?? this.suggestions,
      isBotTyping: isBotTyping ?? this.isBotTyping,
      successMessage:
          clearSuccessMessage ? null : successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
        sessionId,
        messages,
        quickReplies,
        suggestions,
        isBotTyping,
        successMessage
      ];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
  @override
  List<Object> get props => [message];
}
