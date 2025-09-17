import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/history/domain/entities/request_item.dart';
import 'package:satulemari/features/history/domain/usecases/get_my_requests_usecase.dart';
import 'package:satulemari/features/order/domain/entities/order_item.dart';
import 'package:satulemari/features/order/domain/usecases/get_my_orders_usecase.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetMyRequestsUseCase getMyRequests;
  final GetMyOrdersUseCase getMyOrders;

  HistoryBloc({
    required this.getMyRequests,
    required this.getMyOrders,
  }) : super(const HistoryState()) {
    on<FetchAllHistory>(_onFetchAllHistory);
    on<HistoryReset>((event, emit) => emit(const HistoryState()));
    on<RefreshHistory>(_onRefreshHistory);
  }

  Future<void> _onFetchAllHistory(
      FetchAllHistory event, Emitter<HistoryState> emit) async {
    // Set loading hanya jika belum pernah di-load sama sekali
    if (state.requestsStatus == HistoryStatus.initial ||
        state.ordersStatus == HistoryStatus.initial) {
      emit(state.copyWith(
        requestsStatus: HistoryStatus.loading,
        ordersStatus: HistoryStatus.loading,
      ));
    }

    final results = await Future.wait([
      getMyRequests(const GetMyRequestsParams(type: 'donation')),
      getMyRequests(const GetMyRequestsParams(type: 'rental')),
      getMyOrders(NoParams()),
    ]);

    if (isClosed) return;

    final donationRequestsResult =
        results[0] as Either<Failure, List<RequestItem>>;
    final rentalRequestsResult =
        results[1] as Either<Failure, List<RequestItem>>;
    final ordersResult = results[2] as Either<Failure, List<OrderItem>>;

    List<RequestItem> allRequests = [];
    String? requestsError;

    donationRequestsResult.fold(
      (failure) => requestsError = "Gagal memuat permintaan donasi.",
      (data) => allRequests.addAll(data),
    );

    rentalRequestsResult.fold(
      (failure) {
        final rentalError = "Gagal memuat permintaan sewa.";
        requestsError = requestsError == null
            ? rentalError
            : '$requestsError\n$rentalError';
      },
      (data) => allRequests.addAll(data),
    );

    allRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    emit(state.copyWith(
      requestsStatus:
          requestsError == null ? HistoryStatus.loaded : HistoryStatus.error,
      requests: allRequests,
      requestsError: requestsError,
      ordersStatus:
          ordersResult.isRight() ? HistoryStatus.loaded : HistoryStatus.error,
      orders: ordersResult.getOrElse(() => []),
      ordersError: ordersResult.fold((l) => l.message, (r) => null),
    ));
  }

  Future<void> _onRefreshHistory(
      RefreshHistory event, Emitter<HistoryState> emit) async {
    emit(state.copyWith(
      requestsStatus: HistoryStatus.loading,
      requests: [],
      ordersStatus: HistoryStatus.loading,
      orders: [],
    ));
    // Panggil langsung logika fetch-nya, jangan add event baru
    await _onFetchAllHistory(FetchAllHistory(), emit);
  }
}
