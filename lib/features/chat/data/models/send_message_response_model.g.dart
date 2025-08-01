// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_message_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendMessageResponseModel _$SendMessageResponseModelFromJson(
        Map<String, dynamic> json) =>
    SendMessageResponseModel(
      sessionId: json['session_id'] as String,
      message: json['message'] as String,
      messageType: json['message_type'] as String,
      quickReplies: (json['quick_replies'] as List<dynamic>?)
              ?.map((e) => QuickReplyModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      timestamp: DateTime.parse(json['timestamp'] as String),
      canContinue: json['can_continue'] as bool,
      sessionActive: json['session_active'] as bool,
    );

Map<String, dynamic> _$SendMessageResponseModelToJson(
        SendMessageResponseModel instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'message': instance.message,
      'message_type': instance.messageType,
      'timestamp': instance.timestamp.toIso8601String(),
      'can_continue': instance.canContinue,
      'session_active': instance.sessionActive,
      'quick_replies': instance.quickReplies.map((e) => e.toJson()).toList(),
    };
