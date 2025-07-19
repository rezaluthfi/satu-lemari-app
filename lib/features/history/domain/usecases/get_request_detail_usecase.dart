import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/history/domain/entities/request_detail.dart';
import 'package:satulemari/features/history/domain/repositories/history_repository.dart';

class GetRequestDetailUseCase
    implements UseCase<RequestDetail, GetRequestDetailParams> {
  final HistoryRepository repository;
  GetRequestDetailUseCase(this.repository);

  @override
  Future<Either<Failure, RequestDetail>> call(
      GetRequestDetailParams params) async {
    return await repository.getRequestDetail(params.id);
  }
}

class GetRequestDetailParams extends Equatable {
  final String id;
  const GetRequestDetailParams({required this.id});
  @override
  List<Object> get props => [id];
}
