part of 'order_detail_bloc.dart';

abstract class OrderDetailState extends Equatable {
  const OrderDetailState();

  @override
  List<Object> get props => [];
}

class OrderDetailInitial extends OrderDetailState {}

class OrderDetailLoading extends OrderDetailState {}

class OrderDetailLoaded extends OrderDetailState {
  final OrderDetail detail;
  const OrderDetailLoaded(this.detail);

  @override
  List<Object> get props => [detail];
}

class OrderCreateSuccess extends OrderDetailState {
  final String newOrderId;
  const OrderCreateSuccess(this.newOrderId);

  @override
  List<Object> get props => [newOrderId];
}

class OrderDetailError extends OrderDetailState {
  final String message;
  const OrderDetailError(this.message);

  @override
  List<Object> get props => [message];
}

class OrderDetailNotFound extends OrderDetailState {}
