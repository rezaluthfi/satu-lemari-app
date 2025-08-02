import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/history/domain/repositories/history_repository.dart';

class DeleteRequestUseCase implements UseCase<void, DeleteRequestParams> {
  final HistoryRepository repository;
  DeleteRequestUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteRequestParams params) async {
    return await repository.deleteRequest(params.id, params.status);
  }
}

class DeleteRequestParams extends Equatable {
  final String id;
  final String status;
  const DeleteRequestParams({required this.id, required this.status});
  @override
  List<Object> get props => [id, status];
}
