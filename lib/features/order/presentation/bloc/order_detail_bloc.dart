import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/features/order/data/models/create_order_request_model.dart';
import 'package:satulemari/features/order/domain/entities/order_detail.dart';
import 'package:satulemari/features/order/domain/usecases/create_order_usecase.dart';
import 'package:satulemari/features/order/domain/usecases/get_order_detail_usecase.dart';

part 'order_detail_event.dart';
part 'order_detail_state.dart';

class OrderDetailBloc extends Bloc<OrderDetailEvent, OrderDetailState> {
  final GetOrderDetailUseCase getOrderDetail;
  final CreateOrderUseCase createOrder;

  OrderDetailBloc({required this.getOrderDetail, required this.createOrder})
      : super(OrderDetailInitial()) {
    on<FetchOrderDetail>(_onFetchOrderDetail);
    on<CreateOrderButtonPressed>(_onCreateOrder);
  }

  Future<void> _onFetchOrderDetail(
      FetchOrderDetail event, Emitter<OrderDetailState> emit) async {
    emit(OrderDetailLoading());
    final result = await getOrderDetail(event.orderId);
    result.fold(
      (failure) {
        if (failure is NotFoundFailure) {
          emit(OrderDetailNotFound());
        } else {
          emit(OrderDetailError(failure.message));
        }
      },
      (detail) => emit(OrderDetailLoaded(detail)),
    );
  }

  Future<void> _onCreateOrder(
      CreateOrderButtonPressed event, Emitter<OrderDetailState> emit) async {
    emit(OrderDetailLoading());
    final result = await createOrder(CreateOrderParams(request: event.request));
    result.fold(
      (failure) => emit(OrderDetailError(failure.message)),
      (newOrderId) => emit(OrderCreateSuccess(newOrderId)),
    );
  }
}
