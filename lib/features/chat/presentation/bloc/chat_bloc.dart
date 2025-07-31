// lib/features/chat/presentation/bloc/chat_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/chat/domain/usecases/delete_all_message_in_session.dart';
import 'package:satulemari/features/chat/domain/usecases/delete_specific_message.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_suggestion.dart';
import '../../domain/entities/quick_reply.dart';
import '../../domain/usecases/get_chat_history.dart';
import '../../domain/usecases/get_chat_suggestions.dart';
import '../../domain/usecases/send_chat_message.dart';
import '../../domain/usecases/start_chat_session.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final StartChatSession _startChatSession;
  final SendChatMessage _sendChatMessage;
  final GetChatHistory _getChatHistory;
  final GetChatSuggestions _getChatSuggestions;
  final DeleteAllMessagesInSession _deleteAllMessagesInSession;
  final DeleteSpecificMessages _deleteSpecificMessages;

  ChatBloc({
    required StartChatSession startChatSession,
    required SendChatMessage sendChatMessage,
    required GetChatHistory getChatHistory,
    required GetChatSuggestions getChatSuggestions,
    required DeleteAllMessagesInSession deleteAllMessagesInSession,
    required DeleteSpecificMessages deleteSpecificMessages,
  })  : _startChatSession = startChatSession,
        _sendChatMessage = sendChatMessage,
        _getChatHistory = getChatHistory,
        _getChatSuggestions = getChatSuggestions,
        _deleteAllMessagesInSession = deleteAllMessagesInSession,
        _deleteSpecificMessages = deleteSpecificMessages,
        super(ChatInitial()) {
    on<InitializeChat>(_onInitializeChat);
    on<SendTextMessage>(_onSendTextMessage);
    on<QuickReplyTapped>(_onQuickReplyTapped);
    on<ClearSessionMessages>(_onClearSessionMessages);
    on<DeleteSelectedMessagesEvent>(_onDeleteSelectedMessages);
  }

  Future<void> _onInitializeChat(
      InitializeChat event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      String sessionId;
      if (event.existingSessionId != null) {
        sessionId = event.existingSessionId!;
      } else {
        final sessionResult =
            await _startChatSession(const StartChatSessionParams());
        sessionId = sessionResult.fold(
          (failure) =>
              throw Exception("Gagal memulai sesi: ${failure.message}"),
          (session) => session.id,
        );
      }

      final results = await Future.wait([
        _getChatHistory(HistoryParams(sessionId: sessionId)),
        _getChatSuggestions(NoParams()),
      ]);

      final historyResult = results[0] as Either<dynamic, List<ChatMessage>>;
      final initialMessages = historyResult.fold(
        (failure) =>
            throw Exception("Gagal memuat riwayat: ${failure.message}"),
        // PERBAIKAN: Gunakan data langsung dari server tanpa membalik
        // karena server sudah mengirim dalam urutan yang benar
        (messages) => messages,
      );

      final suggestionsResult =
          results[1] as Either<dynamic, List<ChatSuggestion>>;
      final suggestions = suggestionsResult.getOrElse(() => []);

      emit(ChatLoaded(
        sessionId: sessionId,
        messages: initialMessages,
        suggestions: suggestions,
      ));
    } catch (e) {
      emit(ChatError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onSendTextMessage(
      SendTextMessage event, Emitter<ChatState> emit) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      sessionId: currentState.sessionId,
      role: 'user',
      content: event.text,
      timestamp: DateTime.now(),
    );

    // PERBAIKAN: Tambahkan pesan baru di AKHIR list (urutan normal)
    emit(currentState.copyWith(
      messages: [...currentState.messages, userMessage],
      isBotTyping: true,
      quickReplies: [],
      suggestions: [],
    ));

    final result = await _sendChatMessage(SendMessageParams(
      sessionId: currentState.sessionId,
      message: event.text,
    ));

    await result.fold(
      (failure) async {
        final errorMessage = ChatMessage(
          id: const Uuid().v4(),
          sessionId: (state as ChatLoaded).sessionId,
          role: 'assistant',
          content: "Oops, terjadi kesalahan: ${failure.message}",
          timestamp: DateTime.now(),
        );
        // PERBAIKAN: Tambahkan error message di akhir list
        emit((state as ChatLoaded).copyWith(
            messages: [...(state as ChatLoaded).messages, errorMessage],
            isBotTyping: false));
      },
      (response) async {
        final historyResult = await _getChatHistory(
            HistoryParams(sessionId: currentState.sessionId));
        historyResult.fold(
          (failure) {
            emit((state as ChatLoaded).copyWith(isBotTyping: false));
            emit(ChatError("Gagal menyinkronkan pesan: ${failure.message}"));
          },
          (freshMessages) {
            // PERBAIKAN: Gunakan data langsung dari server
            emit((state as ChatLoaded).copyWith(
              messages: freshMessages,
              quickReplies: response.quickReplies,
              isBotTyping: false,
            ));
          },
        );
      },
    );
  }

  void _onQuickReplyTapped(QuickReplyTapped event, Emitter<ChatState> emit) {
    if (state is ChatLoaded) {
      add(SendTextMessage(event.reply.text));
    }
  }

  Future<void> _onClearSessionMessages(
      ClearSessionMessages event, Emitter<ChatState> emit) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final result = await _deleteAllMessagesInSession(
        SessionIdParams(sessionId: currentState.sessionId));
    result.fold(
      (failure) {
        emit(ChatError("Gagal menghapus pesan: ${failure.message}"));
      },
      (_) {
        add(InitializeChat(existingSessionId: currentState.sessionId));
      },
    );
  }

  Future<void> _onDeleteSelectedMessages(
      DeleteSelectedMessagesEvent event, Emitter<ChatState> emit) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final result = await _deleteSpecificMessages(DeleteSpecificMessagesParams(
      sessionId: currentState.sessionId,
      messageIds: event.messageIds,
    ));

    await result.fold(
      (failure) async {
        emit(ChatError("Gagal menghapus pesan: ${failure.message}"));
      },
      (_) async {
        final historyResult = await _getChatHistory(
            HistoryParams(sessionId: currentState.sessionId));

        historyResult.fold(
          (failure) {
            emit(ChatError(
                "Pesan dihapus, tapi gagal memuat ulang: ${failure.message}"));
          },
          (freshMessages) {
            // PERBAIKAN: Gunakan data langsung dari server
            emit(currentState.copyWith(
              messages: freshMessages,
              successMessage:
                  "${event.messageIds.length} pesan berhasil dihapus.",
            ));
          },
        );
      },
    );
  }
}
