part of 'history_bloc.dart';

enum HistoryStatus { initial, loading, loaded, error }

class HistoryState extends Equatable {
  // State untuk Requests
  final HistoryStatus requestsStatus;
  final List<RequestItem> requests;
  final String? requestsError;
  final bool requestsIsLoadingMore;
  final bool requestsHasReachedEnd;
  final int requestsCurrentPage;

  // State untuk Orders
  final HistoryStatus ordersStatus;
  final List<OrderItem> orders;
  final String? ordersError;
  final bool ordersIsLoadingMore;
  final bool ordersHasReachedEnd;
  final int ordersCurrentPage;

  const HistoryState({
    this.requestsStatus = HistoryStatus.initial,
    this.requests = const [],
    this.requestsError,
    this.requestsIsLoadingMore = false,
    this.requestsHasReachedEnd = false,
    this.requestsCurrentPage = 1,
    this.ordersStatus = HistoryStatus.initial,
    this.orders = const [],
    this.ordersError,
    this.ordersIsLoadingMore = false,
    this.ordersHasReachedEnd = false,
    this.ordersCurrentPage = 1,
  });

  HistoryState copyWith({
    HistoryStatus? requestsStatus,
    List<RequestItem>? requests,
    String? requestsError,
    bool? requestsIsLoadingMore,
    bool? requestsHasReachedEnd,
    int? requestsCurrentPage,
    HistoryStatus? ordersStatus,
    List<OrderItem>? orders,
    String? ordersError,
    bool? ordersIsLoadingMore,
    bool? ordersHasReachedEnd,
    int? ordersCurrentPage,
  }) {
    return HistoryState(
      requestsStatus: requestsStatus ?? this.requestsStatus,
      requests: requests ?? this.requests,
      requestsError: requestsError ?? this.requestsError,
      requestsIsLoadingMore:
          requestsIsLoadingMore ?? this.requestsIsLoadingMore,
      requestsHasReachedEnd:
          requestsHasReachedEnd ?? this.requestsHasReachedEnd,
      requestsCurrentPage: requestsCurrentPage ?? this.requestsCurrentPage,
      ordersStatus: ordersStatus ?? this.ordersStatus,
      orders: orders ?? this.orders,
      ordersError: ordersError ?? this.ordersError,
      ordersIsLoadingMore: ordersIsLoadingMore ?? this.ordersIsLoadingMore,
      ordersHasReachedEnd: ordersHasReachedEnd ?? this.ordersHasReachedEnd,
      ordersCurrentPage: ordersCurrentPage ?? this.ordersCurrentPage,
    );
  }

  @override
  List<Object?> get props => [
        requestsStatus,
        requests,
        requestsError,
        requestsIsLoadingMore,
        requestsHasReachedEnd,
        requestsCurrentPage,
        ordersStatus,
        orders,
        ordersError,
        ordersIsLoadingMore,
        ordersHasReachedEnd,
        ordersCurrentPage,
      ];
}
