import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/request/data/models/create_request_model.dart';
import 'package:satulemari/features/request/domain/repositories/request_repository.dart';

class CreateRequestUseCase implements UseCase<String, CreateRequestParams> {
  final RequestRepository repository;
  CreateRequestUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(CreateRequestParams params) async {
    return await repository.createRequest(params.request);
  }
}

class CreateRequestParams extends Equatable {
  final CreateRequestModel request;
  const CreateRequestParams({required this.request});
  @override
  List<Object> get props => [request];
}
