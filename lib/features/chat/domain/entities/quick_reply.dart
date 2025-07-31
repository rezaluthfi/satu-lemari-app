// lib/features/chat/domain/entities/quick_reply.dart
import 'package:equatable/equatable.dart';

class QuickReply extends Equatable {
  final String text;
  final String payload;
  final String? icon;

  const QuickReply({required this.text, required this.payload, this.icon});

  @override
  List<Object?> get props => [text, payload, icon];
}
