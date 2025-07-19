import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/history/domain/entities/request_item.dart';
import 'package:satulemari/features/history/domain/repositories/history_repository.dart';

class GetMyRequestsUseCase
    implements UseCase<List<RequestItem>, GetMyRequestsParams> {
  final HistoryRepository repository;
  GetMyRequestsUseCase(this.repository);

  @override
  Future<Either<Failure, List<RequestItem>>> call(
      GetMyRequestsParams params) async {
    return await repository.getMyRequests(params.type);
  }
}

class GetMyRequestsParams extends Equatable {
  final String type; // 'donation' or 'rental'
  const GetMyRequestsParams({required this.type});
  @override
  List<Object> get props => [type];
}
