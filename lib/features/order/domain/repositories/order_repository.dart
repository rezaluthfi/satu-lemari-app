import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/features/order/data/models/create_order_request_model.dart';

import 'package:satulemari/features/order/domain/entities/create_order_response.dart';
import 'package:satulemari/features/order/domain/entities/order_detail.dart';
import 'package:satulemari/features/order/domain/entities/order_item.dart';

abstract class OrderRepository {
  Future<Either<Failure, CreateOrderResponseEntity>> createOrder(
      CreateOrderRequestModel request);
  Future<Either<Failure, OrderDetail>> getOrderDetail(String orderId);
  Future<Either<Failure, List<OrderItem>>> getMyOrders();
  Future<Either<Failure, void>> cancelOrder(String orderId);
}
