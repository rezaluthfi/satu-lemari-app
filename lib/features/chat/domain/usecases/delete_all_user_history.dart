import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

class DeleteAllUserHistory implements UseCase<void, NoParams> {
  final ChatRepository repository;
  DeleteAllUserHistory(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.deleteAllUserHistory();
  }
}
