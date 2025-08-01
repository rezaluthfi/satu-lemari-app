// lib/features/chat/data/models/send_message_response_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'quick_reply_model.dart';
import '../../domain/entities/send_message_response.dart';

part 'send_message_response_model.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class SendMessageResponseModel extends SendMessageResponse {
  @JsonKey(defaultValue: [])
  @override
  final List<QuickReplyModel> quickReplies;

  const SendMessageResponseModel({
    required String sessionId,
    required String message,
    required String messageType,
    required this.quickReplies,
    required DateTime timestamp,
    required bool canContinue,
    required bool sessionActive,
  }) : super(
          sessionId: sessionId,
          message: message,
          messageType: messageType,
          quickReplies: quickReplies,
          timestamp: timestamp,
          canContinue: canContinue,
          sessionActive: sessionActive,
        );

  factory SendMessageResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SendMessageResponseModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SendMessageResponseModelToJson(this);
}
