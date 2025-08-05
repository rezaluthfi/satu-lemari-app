import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/exceptions.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/network/network_info.dart';
import 'package:satulemari/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:satulemari/features/chat/domain/entities/chat_message.dart';
import 'package:satulemari/features/chat/domain/entities/chat_session.dart';
import 'package:satulemari/features/chat/domain/entities/chat_suggestion.dart';
import 'package:satulemari/features/chat/domain/entities/send_message_response.dart';
import 'package:satulemari/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ChatRepositoryImpl(
      {required this.remoteDataSource, required this.networkInfo});

  Future<Either<Failure, T>> _handleRequest<T>(
      Future<T> Function() call) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await call();
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('No internet connection.'));
    }
  }

  @override
  Future<Either<Failure, ChatSession>> startChatSession(
      {String language = 'id'}) {
    return _handleRequest(
        () => remoteDataSource.startChatSession(language: language));
  }

  @override
  Future<Either<Failure, SendMessageResponse>> sendMessage({
    required String sessionId,
    required String message,
    Map<String, dynamic>? context,
  }) {
    return _handleRequest(() => remoteDataSource.sendMessage(
        sessionId: sessionId, message: message, context: context));
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getChatHistory(String sessionId) {
    return _handleRequest(() => remoteDataSource.getChatHistory(sessionId));
  }

  @override
  Future<Either<Failure, List<ChatSession>>> getUserSessions(
      {int limit = 20, int offset = 0}) {
    return _handleRequest(
        () => remoteDataSource.getUserSessions(limit: limit, offset: offset));
  }

  @override
  Future<Either<Failure, List<ChatSuggestion>>> getChatSuggestions() {
    return _handleRequest(() => remoteDataSource.getChatSuggestions());
  }

  @override
  Future<Either<Failure, void>> deleteChatSession(String sessionId) {
    return _handleRequest(() => remoteDataSource.deleteChatSession(sessionId));
  }

  @override
  Future<Either<Failure, void>> deleteAllUserHistory() {
    return _handleRequest(() => remoteDataSource.deleteAllUserHistory());
  }

  @override
  Future<Either<Failure, void>> deleteSpecificMessages(
      {required String sessionId, required List<String> messageIds}) {
    return _handleRequest(() => remoteDataSource.deleteSpecificMessages(
        sessionId: sessionId, messageIds: messageIds));
  }

  @override
  Future<Either<Failure, void>> deleteAllMessagesInSession(String sessionId) {
    return _handleRequest(
        () => remoteDataSource.deleteAllMessagesInSession(sessionId));
  }
}
