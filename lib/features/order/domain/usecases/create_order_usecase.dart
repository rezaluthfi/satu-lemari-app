import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/order/data/models/create_order_request_model.dart';
import 'package:satulemari/features/order/domain/entities/create_order_response.dart';
import 'package:satulemari/features/order/domain/repositories/order_repository.dart';

class CreateOrderUseCase
    implements UseCase<CreateOrderResponseEntity, CreateOrderParams> {
  final OrderRepository repository;
  CreateOrderUseCase(this.repository);

  @override
  Future<Either<Failure, CreateOrderResponseEntity>> call(
      CreateOrderParams params) async {
    return await repository.createOrder(params.request);
  }
}

class CreateOrderParams extends Equatable {
  final CreateOrderRequestModel request;
  const CreateOrderParams({required this.request});

  @override
  List<Object> get props => [request];
}
