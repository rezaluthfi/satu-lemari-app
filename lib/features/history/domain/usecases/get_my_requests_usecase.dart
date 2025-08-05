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
    return await repository.getMyRequests(params);
  }
}

class GetMyRequestsParams extends Equatable {
  final String type; // 'donation' or 'rental'
  final int page;
  final int limit;

  const GetMyRequestsParams({
    required this.type,
    this.page = 1,
    this.limit = 10,
  });

  /// Calculate offset from page and limit
  int get offset => (page - 1) * limit;

  /// Create a copy with new pagination parameters
  GetMyRequestsParams copyWithPagination({int? page, int? limit}) {
    return GetMyRequestsParams(
      type: type,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  @override
  List<Object> get props => [type, page, limit];
}
