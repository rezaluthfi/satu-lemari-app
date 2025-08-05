import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/chat_suggestion.dart';

part 'chat_suggestion_model.g.dart';

@JsonSerializable()
class ChatSuggestionModel extends ChatSuggestion {
  const ChatSuggestionModel({
    required String text,
    required String category,
    String? description,
  }) : super(text: text, category: category, description: description);

  factory ChatSuggestionModel.fromJson(Map<String, dynamic> json) =>
      _$ChatSuggestionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatSuggestionModelToJson(this);
}
