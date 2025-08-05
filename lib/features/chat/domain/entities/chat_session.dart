import 'package:equatable/equatable.dart';

class ChatSession extends Equatable {
  final String id;
  final String userId;
  final DateTime createdAt;
  final DateTime lastActivity;
  final Map<String, dynamic> context;
  final bool isActive;

  const ChatSession({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.lastActivity,
    required this.context,
    required this.isActive,
  });

  @override
  List<Object?> get props =>
      [id, userId, createdAt, lastActivity, context, isActive];
}
