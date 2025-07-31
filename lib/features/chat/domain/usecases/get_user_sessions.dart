// lib/features/chat/domain/usecases/get_user_sessions.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import '../entities/chat_session.dart';
import '../repositories/chat_repository.dart';

class GetUserSessions
    implements UseCase<List<ChatSession>, GetUserSessionsParams> {
  final ChatRepository repository;
  GetUserSessions(this.repository);

  @override
  Future<Either<Failure, List<ChatSession>>> call(
      GetUserSessionsParams params) async {
    return await repository.getUserSessions(
        limit: params.limit, offset: params.offset);
  }
}

class GetUserSessionsParams extends Equatable {
  final int limit;
  final int offset;

  const GetUserSessionsParams({this.limit = 20, this.offset = 0});

  @override
  List<Object> get props => [limit, offset];
}
