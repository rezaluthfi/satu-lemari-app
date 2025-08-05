import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/chat_message.dart';

part 'chat_message_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required String id,
    String? sessionId,
    required String role,
    required String content,
    required DateTime timestamp,
  }) : super(
          id: id,
          sessionId: sessionId,
          role: role,
          content: content,
          timestamp: timestamp,
        );

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageModelToJson(this);
}
