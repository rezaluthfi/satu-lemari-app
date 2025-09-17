part of 'order_detail_bloc.dart';

abstract class OrderDetailState extends Equatable {
  const OrderDetailState();

  @override
  List<Object?> get props => [];
}

class OrderDetailInitial extends OrderDetailState {}

class OrderDetailLoading extends OrderDetailState {}

class OrderDetailLoaded extends OrderDetailState {
  final OrderDetail detail;
  final ItemDetail? itemDetail;

  const OrderDetailLoaded({required this.detail, this.itemDetail});

  @override
  List<Object?> get props => [detail, itemDetail];

  OrderDetailLoaded copyWith({
    OrderDetail? detail,
    ItemDetail? itemDetail,
  }) {
    return OrderDetailLoaded(
      detail: detail ?? this.detail,
      itemDetail: itemDetail ?? this.itemDetail,
    );
  }
}

class OrderCreateSuccess extends OrderDetailState {
  final String newOrderId;
  const OrderCreateSuccess(this.newOrderId);

  @override
  List<Object> get props => [newOrderId];
}

class OrderCancelSuccess extends OrderDetailState {}

class OrderCancelFailure extends OrderDetailState {
  final String message;
  const OrderCancelFailure(this.message);

  @override
  List<Object> get props => [message];
}

class OrderDetailError extends OrderDetailState {
  final String message;
  const OrderDetailError(this.message);

  @override
  List<Object> get props => [message];
}

class OrderDetailNotFound extends OrderDetailState {}
