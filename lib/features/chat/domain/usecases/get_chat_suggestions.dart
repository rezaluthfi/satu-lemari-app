// lib/features/chat/domain/usecases/get_chat_suggestions.dart
import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import '../entities/chat_suggestion.dart';
import '../repositories/chat_repository.dart';

class GetChatSuggestions implements UseCase<List<ChatSuggestion>, NoParams> {
  final ChatRepository repository;
  GetChatSuggestions(this.repository);

  @override
  Future<Either<Failure, List<ChatSuggestion>>> call(NoParams params) async {
    return await repository.getChatSuggestions();
  }
}
