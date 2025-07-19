import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/features/history/domain/entities/request_detail.dart';
import 'package:satulemari/features/request/data/models/create_request_model.dart';

abstract class RequestRepository {
  Future<Either<Failure, RequestDetail>> createRequest(
      CreateRequestModel request);
}
