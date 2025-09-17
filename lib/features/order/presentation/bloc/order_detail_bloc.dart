import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/features/item_detail/domain/entities/item_detail.dart';
import 'package:satulemari/features/item_detail/domain/usecases/get_item_by_id_usecase.dart';
import 'package:satulemari/features/order/data/models/create_order_request_model.dart';
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

    // Gunakan fold untuk menangani hasil dari panggilan pertama
    await orderResult.fold(
      // Jika panggilan pertama (get order) gagal, langsung emit error
      (failure) async {
        if (failure is NotFoundFailure) {
          emit(OrderDetailNotFound());
        } else {
          emit(OrderDetailError(failure.message));
        }
      },
      // Jika panggilan pertama berhasil, lanjutkan ke panggilan kedua
      (orderDetail) async {
        final itemResult =
            await getItemById(GetItemByIdParams(id: orderDetail.itemId));

        if (isClosed) return;

        // Gunakan fold lagi untuk menangani hasil dari panggilan kedua
        itemResult.fold((itemFailure) {
          // Jika panggilan kedua (get item) gagal, tetap punya data order.
          // Tampilkan halaman dengan pesan error di bagian item,
          // atau (lebih baik) anggap sebagai error keseluruhan.
          emit(OrderDetailError(
              "Gagal memuat detail barang: ${itemFailure.message}"));
        }, (itemDetail) {
          // HANYA JIKA KEDUA PANGGILAN BERHASIL, kita emit state Loaded
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
      (newOrderId) => emit(OrderCreateSuccess(newOrderId)),
    );
  }

  Future<void> _onCancelOrder(
      CancelOrderButtonPressed event, Emitter<OrderDetailState> emit) async {
    // Tidak ingin seluruh halaman menjadi loading, jadi tidak emit OrderDetailLoading di sini
    final result = await cancelOrder(event.orderId);

    result.fold(
      (failure) {
        emit(OrderCancelFailure(failure.message));
        // Fetch ulang data untuk mengembalikan UI ke state sebelum tombol ditekan jika gagal
        add(FetchOrderDetail(event.orderId));
      },
      (_) {
        emit(OrderCancelSuccess());
        // Fetch ulang data untuk menampilkan status "cancelled" yang baru
        add(FetchOrderDetail(event.orderId));
      },
    );
  }
}
