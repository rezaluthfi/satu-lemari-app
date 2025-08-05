import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

class DeleteAllMessagesInSession implements UseCase<void, SessionIdParams> {
  final ChatRepository repository;
  DeleteAllMessagesInSession(this.repository);

  @override
  Future<Either<Failure, void>> call(SessionIdParams params) async {
    return await repository.deleteAllMessagesInSession(params.sessionId);
  }
}

// Params ini bisa direuse untuk use case lain yang hanya butuh sessionId
class SessionIdParams extends Equatable {
  final String sessionId;
  const SessionIdParams({required this.sessionId});
  @override
  List<Object> get props => [sessionId];
}
