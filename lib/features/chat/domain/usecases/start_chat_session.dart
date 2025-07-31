// lib/features/chat/domain/usecases/start_chat_session.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import '../entities/chat_session.dart';
import '../repositories/chat_repository.dart';

class StartChatSession implements UseCase<ChatSession, StartChatSessionParams> {
  final ChatRepository repository;

  StartChatSession(this.repository);

  @override
  Future<Either<Failure, ChatSession>> call(
      StartChatSessionParams params) async {
    return await repository.startChatSession(language: params.language);
  }
}

class StartChatSessionParams extends Equatable {
  final String language;
  const StartChatSessionParams({this.language = 'id'});
  @override
  List<Object> get props => [language];
}
