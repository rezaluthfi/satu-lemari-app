import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/order/domain/entities/order_detail.dart';
import 'package:satulemari/features/order/domain/repositories/order_repository.dart';

class GetOrderDetailUseCase implements UseCase<OrderDetail, String> {
  final OrderRepository repository;
  GetOrderDetailUseCase(this.repository);

  @override
  Future<Either<Failure, OrderDetail>> call(String orderId) async {
    return await repository.getOrderDetail(orderId);
  }
}
