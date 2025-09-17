import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/order/domain/entities/order_item.dart';
import 'package:satulemari/features/order/domain/repositories/order_repository.dart';

class GetMyOrdersUseCase implements UseCase<List<OrderItem>, NoParams> {
  final OrderRepository repository;
  GetMyOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, List<OrderItem>>> call(NoParams params) async {
    return await repository.getMyOrders();
  }
}
