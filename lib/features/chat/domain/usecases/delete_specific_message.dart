import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

class DeleteSpecificMessages
    implements UseCase<void, DeleteSpecificMessagesParams> {
  final ChatRepository repository;
  DeleteSpecificMessages(this.repository);

  @override
  Future<Either<Failure, void>> call(
      DeleteSpecificMessagesParams params) async {
    return await repository.deleteSpecificMessages(
        sessionId: params.sessionId, messageIds: params.messageIds);
  }
}

class DeleteSpecificMessagesParams extends Equatable {
  final String sessionId;
  final List<String> messageIds;

  const DeleteSpecificMessagesParams(
      {required this.sessionId, required this.messageIds});

  @override
  List<Object> get props => [sessionId, messageIds];
}
