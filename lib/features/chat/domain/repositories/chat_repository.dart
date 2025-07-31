// lib/features/chat/domain/repositories/chat_repository.dart
import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/failures.dart';
import '../entities/chat_session.dart';
import '../entities/chat_message.dart';
import '../entities/chat_suggestion.dart';
import '../entities/send_message_response.dart';

abstract class ChatRepository {
  Future<Either<Failure, ChatSession>> startChatSession({String language});
  Future<Either<Failure, SendMessageResponse>> sendMessage({
    required String sessionId,
    required String message,
    Map<String, dynamic>? context,
  });
  Future<Either<Failure, List<ChatMessage>>> getChatHistory(String sessionId);
  Future<Either<Failure, List<ChatSession>>> getUserSessions(
      {int limit, int offset});
  Future<Either<Failure, List<ChatSuggestion>>> getChatSuggestions();
  Future<Either<Failure, void>> deleteSpecificMessages(
      {required String sessionId, required List<String> messageIds});
  Future<Either<Failure, void>> deleteAllMessagesInSession(String sessionId);
  Future<Either<Failure, void>> deleteChatSession(String sessionId);
  Future<Either<Failure, void>> deleteAllUserHistory();
}
