import 'package:satulemari/features/browse/domain/entities/ai_suggestions.dart';

class AiSuggestionsModel extends AiSuggestions {
  const AiSuggestionsModel({
    required super.query,
    required super.suggestions,
  });

  factory AiSuggestionsModel.fromJson(Map<String, dynamic> json) {
    return AiSuggestionsModel(
      query: json['data']['query'] ?? '',
      suggestions: List<String>.from(json['data']['suggestions'] ?? []),
    );
  }
}
