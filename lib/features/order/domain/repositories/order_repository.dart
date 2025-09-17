import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/features/order/data/models/create_order_request_model.dart';
import 'package:satulemari/features/order/domain/entities/order_detail.dart';

abstract class OrderRepository {
  Future<Either<Failure, String>> createOrder(CreateOrderRequestModel request);
  Future<Either<Failure, OrderDetail>> getOrderDetail(String orderId);
}
