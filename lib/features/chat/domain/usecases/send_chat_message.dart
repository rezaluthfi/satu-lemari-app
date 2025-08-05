import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import '../entities/send_message_response.dart';
import '../repositories/chat_repository.dart';

class SendChatMessage
    implements UseCase<SendMessageResponse, SendMessageParams> {
  final ChatRepository repository;
  SendChatMessage(this.repository);

  @override
  Future<Either<Failure, SendMessageResponse>> call(
      SendMessageParams params) async {
    return await repository.sendMessage(
      sessionId: params.sessionId,
      message: params.message,
      context: params.context,
    );
  }
}

class SendMessageParams extends Equatable {
  final String sessionId;
  final String message;
  final Map<String, dynamic>? context;

  const SendMessageParams(
      {required this.sessionId, required this.message, this.context});

  @override
  List<Object?> get props => [sessionId, message, context];
}
