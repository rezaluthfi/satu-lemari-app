import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:satulemari/core/constants/app_urls.dart';
import 'package:satulemari/core/errors/exceptions.dart';
import '../models/chat_session_model.dart';
import '../models/chat_message_model.dart';
import '../models/chat_suggestion_model.dart';
import '../models/send_message_response_model.dart';

abstract class ChatRemoteDataSource {
  Future<ChatSessionModel> startChatSession({String language});
  Future<SendMessageResponseModel> sendMessage({
    required String sessionId,
    required String message,
    Map<String, dynamic>? context,
  });
  Future<List<ChatMessageModel>> getChatHistory(String sessionId);
  Future<List<ChatSessionModel>> getUserSessions({int limit, int offset});
  Future<List<ChatSuggestionModel>> getChatSuggestions();
  Future<void> deleteSpecificMessages(
      {required String sessionId, required List<String> messageIds});
  Future<void> deleteAllMessagesInSession(String sessionId);
  Future<void> deleteChatSession(String sessionId);
  Future<void> deleteAllUserHistory();
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio dio;
  ChatRemoteDataSourceImpl({required this.dio});

  Future<T> _handleRequest<T>(
      Future<Response> request, T Function(dynamic data) onSuccess) async {
    try {
      final response = await request;
      final responseData = response.data['data'];

      if (kDebugMode) {
        debugPrint('✅ [Chat API Response] URL: ${response.requestOptions.uri}');
        debugPrint('✅ [Chat API Response] Raw Data: $responseData');
      }

      return onSuccess(responseData);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'An unknown error occurred.';
      if (kDebugMode) {
        debugPrint('❌ [Chat API Error] URL: ${e.requestOptions.uri}');
        debugPrint('❌ [Chat API Error] Message: $message');
      }
      throw ServerException(message: message.toString());
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [Chat Parsing Error] Error: $e');
        debugPrint('❌ [Chat Parsing Error] StackTrace: $stackTrace');
      }
      throw ServerException(
          message: 'Failed to parse server response. Check logs.');
    }
  }

  @override
  Future<ChatSessionModel> startChatSession({String language = 'id'}) {
    return _handleRequest(
      dio.post(AppUrls.chatStart, data: {'language': language}),
      (data) => ChatSessionModel.fromJson(data),
    );
  }

  @override
  Future<SendMessageResponseModel> sendMessage({
    required String sessionId,
    required String message,
    Map<String, dynamic>? context,
  }) {
    return _handleRequest(
      dio.post(AppUrls.chatSend, data: {
        'session_id': sessionId,
        'message': message,
        'context': context,
      }),
      (data) => SendMessageResponseModel.fromJson(data),
    );
  }

  @override
  Future<List<ChatMessageModel>> getChatHistory(String sessionId) {
    return _handleRequest(dio.get('${AppUrls.chatHistoryBase}/$sessionId'),
        (data) {
      if (data['messages'] == null) return [];
      return (data['messages'] as List)
          .map((msg) => ChatMessageModel.fromJson(msg))
          .toList();
    });
  }

  @override
  Future<List<ChatSessionModel>> getUserSessions(
      {int limit = 20, int offset = 0}) {
    return _handleRequest(
        dio.get(AppUrls.chatSessions,
            queryParameters: {'limit': limit, 'offset': offset}), (data) {
      if (data['sessions'] == null) return [];
      return (data['sessions'] as List)
          .map((s) => ChatSessionModel.fromJson(s))
          .toList();
    });
  }

  @override
  Future<List<ChatSuggestionModel>> getChatSuggestions() {
    return _handleRequest(dio.get(AppUrls.chatSuggestions), (data) {
      if (data['suggestions'] == null) return [];
      return (data['suggestions'] as List)
          .map((s) => ChatSuggestionModel.fromJson(s))
          .toList();
    });
  }

  @override
  Future<void> deleteChatSession(String sessionId) {
    return _handleRequest(
      dio.delete('${AppUrls.chatDeleteSessionBase}/$sessionId'),
      (data) => null,
    );
  }

  @override
  Future<void> deleteAllUserHistory() {
    return _handleRequest(
      dio.delete(AppUrls.chatDeleteAllUserHistory),
      (data) => null,
    );
  }

  @override
  Future<void> deleteSpecificMessages(
      {required String sessionId, required List<String> messageIds}) {
    return _handleRequest(
      dio.delete('${AppUrls.chatDeleteMessagesBase}/$sessionId/messages',
          data: {'message_ids': messageIds}),
      (data) => null,
    );
  }

  @override
  Future<void> deleteAllMessagesInSession(String sessionId) {
    return _handleRequest(
      dio.delete(
          '${AppUrls.chatDeleteAllMessagesBase}/$sessionId/messages/all'),
      (data) => null,
    );
  }
}
