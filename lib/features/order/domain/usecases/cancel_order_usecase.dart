import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/order/domain/repositories/order_repository.dart';

class CancelOrderUseCase implements UseCase<void, String> {
  final OrderRepository repository;
  CancelOrderUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String orderId) async {
    return await repository.cancelOrder(orderId);
  }
}
