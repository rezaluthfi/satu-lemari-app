// lib/features/chat/domain/entities/chat_message.dart
import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String? sessionId;
  final String role;
  final String content;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    this.sessionId,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, sessionId, role, content, timestamp];
}
