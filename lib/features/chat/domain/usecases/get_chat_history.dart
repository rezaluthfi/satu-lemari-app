import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class GetChatHistory implements UseCase<List<ChatMessage>, HistoryParams> {
  final ChatRepository repository;
  GetChatHistory(this.repository);

  @override
  Future<Either<Failure, List<ChatMessage>>> call(HistoryParams params) async {
    return await repository.getChatHistory(params.sessionId);
  }
}

class HistoryParams extends Equatable {
  final String sessionId;
  const HistoryParams({required this.sessionId});
  @override
  List<Object> get props => [sessionId];
}
