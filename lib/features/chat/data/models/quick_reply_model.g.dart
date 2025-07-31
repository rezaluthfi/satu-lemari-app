// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quick_reply_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuickReplyModel _$QuickReplyModelFromJson(Map<String, dynamic> json) =>
    QuickReplyModel(
      text: json['text'] as String,
      payload: json['payload'] as String,
      icon: json['icon'] as String?,
    );

Map<String, dynamic> _$QuickReplyModelToJson(QuickReplyModel instance) =>
    <String, dynamic>{
      'text': instance.text,
      'payload': instance.payload,
      'icon': instance.icon,
    };
