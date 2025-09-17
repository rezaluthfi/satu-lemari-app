part of 'order_detail_bloc.dart';

abstract class OrderDetailEvent extends Equatable {
  const OrderDetailEvent();

  @override
  List<Object> get props => [];
}

class FetchOrderDetail extends OrderDetailEvent {
  final String orderId;
  const FetchOrderDetail(this.orderId);

  @override
  List<Object> get props => [orderId];
}

class CreateOrderButtonPressed extends OrderDetailEvent {
  final CreateOrderRequestModel request;
  const CreateOrderButtonPressed(this.request);

  @override
  List<Object> get props => [request];
}
