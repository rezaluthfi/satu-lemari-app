import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/features/item_detail/domain/entities/item_detail.dart';
import 'package:satulemari/features/item_detail/domain/usecases/get_item_by_id_usecase.dart';
import 'package:satulemari/features/order/data/models/create_order_request_model.dart';
import 'package:satulemari/features/order/domain/entities/create_order_response.dart';
import 'package:satulemari/features/order/domain/entities/order_detail.dart';
import 'package:satulemari/features/order/domain/usecases/cancel_order_usecase.dart';
import 'package:satulemari/features/order/domain/usecases/create_order_usecase.dart';
import 'package:satulemari/features/order/domain/usecases/get_order_detail_usecase.dart';

part 'order_detail_event.dart';
part 'order_detail_state.dart';

class OrderDetailBloc extends Bloc<OrderDetailEvent, OrderDetailState> {
  final GetOrderDetailUseCase getOrderDetail;
  final GetItemByIdUseCase getItemById;
  final CreateOrderUseCase createOrder;
  final CancelOrderUseCase cancelOrder;

  String? get orderId => (state is OrderDetailLoaded)
      ? (state as OrderDetailLoaded).detail.id
      : null;

  OrderDetailBloc({
    required this.getOrderDetail,
    required this.getItemById,
    required this.createOrder,
    required this.cancelOrder,
  }) : super(OrderDetailInitial()) {
    on<FetchOrderDetail>(_onFetchOrderDetail);
    on<CreateOrderButtonPressed>(_onCreateOrder);
    on<CancelOrderButtonPressed>(_onCancelOrder);
  }

  Future<void> _onFetchOrderDetail(
      FetchOrderDetail event, Emitter<OrderDetailState> emit) async {
    emit(OrderDetailLoading());
    final orderResult = await getOrderDetail(event.orderId);

    if (isClosed) return;

    await orderResult.fold(
      (failure) async {
        if (failure is NotFoundFailure) {
          emit(OrderDetailNotFound());
        } else {
          emit(OrderDetailError(failure.message));
        }
      },
      (orderDetail) async {
        final itemResult =
            await getItemById(GetItemByIdParams(id: orderDetail.itemId));

        if (isClosed) return;

        itemResult.fold((itemFailure) {
          emit(OrderDetailError(
              "Gagal memuat detail barang: ${itemFailure.message}"));
        }, (itemDetail) {
          emit(OrderDetailLoaded(detail: orderDetail, itemDetail: itemDetail));
        });
      },
    );
  }

  Future<void> _onCreateOrder(
      CreateOrderButtonPressed event, Emitter<OrderDetailState> emit) async {
    emit(OrderDetailLoading());
    final result = await createOrder(CreateOrderParams(request: event.request));
    result.fold(
      (failure) => emit(OrderDetailError(failure.message)),
      (response) => emit(OrderCreateSuccess(response)),
    );
  }

  Future<void> _onCancelOrder(
      CancelOrderButtonPressed event, Emitter<OrderDetailState> emit) async {
    final result = await cancelOrder(event.orderId);

    result.fold(
      (failure) {
        emit(OrderCancelFailure(failure.message));
        add(FetchOrderDetail(event.orderId));
      },
      (_) {
        emit(OrderCancelSuccess());
        add(FetchOrderDetail(event.orderId));
      },
    );
  }
}
