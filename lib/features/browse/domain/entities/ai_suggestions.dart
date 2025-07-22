import 'package:equatable/equatable.dart';

class AiSuggestions extends Equatable {
  final String query;
  final List<String> suggestions;

  const AiSuggestions({required this.query, required this.suggestions});

  @override
  List<Object?> get props => [query, suggestions];
}
