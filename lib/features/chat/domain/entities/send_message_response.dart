import 'package:equatable/equatable.dart';
import 'quick_reply.dart';

class SendMessageResponse extends Equatable {
  final String sessionId;
  final String message;
  final String messageType;
  final List<QuickReply> quickReplies;
  final DateTime timestamp;
  final bool canContinue;
  final bool sessionActive;

  const SendMessageResponse({
    required this.sessionId,
    required this.message,
    required this.messageType,
    required this.quickReplies,
    required this.timestamp,
    required this.canContinue,
    required this.sessionActive,
  });

  @override
  List<Object?> get props => [
        sessionId,
        message,
        messageType,
        quickReplies,
        timestamp,
        canContinue,
        sessionActive
      ];
}
