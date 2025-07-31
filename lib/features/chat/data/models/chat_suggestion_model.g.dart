// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_suggestion_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatSuggestionModel _$ChatSuggestionModelFromJson(Map<String, dynamic> json) =>
    ChatSuggestionModel(
      text: json['text'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$ChatSuggestionModelToJson(
        ChatSuggestionModel instance) =>
    <String, dynamic>{
      'text': instance.text,
      'category': instance.category,
      'description': instance.description,
    };
