// lib/features/chat/domain/usecases/delete_chat_session.dart
import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/chat/domain/usecases/delete_all_message_in_session.dart';
import '../repositories/chat_repository.dart';

class DeleteChatSession implements UseCase<void, SessionIdParams> {
  final ChatRepository repository;
  DeleteChatSession(this.repository);

  @override
  Future<Either<Failure, void>> call(SessionIdParams params) async {
    return await repository.deleteChatSession(params.sessionId);
  }
}
