// lib/features/chat/domain/entities/chat_suggestion.dart
import 'package:equatable/equatable.dart';

class ChatSuggestion extends Equatable {
  final String text;
  final String category;
  final String? description;

  const ChatSuggestion({
    required this.text,
    required this.category,
    this.description,
  });

  @override
  List<Object?> get props => [text, category, description];
}
