import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/features/request/data/models/create_request_model.dart';

abstract class RequestRepository {
  Future<Either<Failure, String>> createRequest(CreateRequestModel request);
}
