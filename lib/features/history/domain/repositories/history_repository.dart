import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/features/history/domain/entities/request_detail.dart';
import 'package:satulemari/features/history/domain/entities/request_item.dart';

abstract class HistoryRepository {
  Future<Either<Failure, List<RequestItem>>> getMyRequests(String type);
  Future<Either<Failure, RequestDetail>> getRequestDetail(String id);
  Future<Either<Failure, void>> deleteRequest(String id, String status);
}
