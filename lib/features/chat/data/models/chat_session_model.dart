import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/chat_session.dart';

part 'chat_session_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ChatSessionModel extends ChatSession {
  const ChatSessionModel({
    required String id,
    required String userId,
    required DateTime createdAt,
    required DateTime lastActivity,
    required Map<String, dynamic> context,
    required bool isActive,
  }) : super(
          id: id,
          userId: userId,
          createdAt: createdAt,
          lastActivity: lastActivity,
          context: context,
          isActive: isActive,
        );

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatSessionModelToJson(this);
}
