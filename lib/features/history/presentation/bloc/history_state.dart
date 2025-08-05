part of 'history_bloc.dart';

enum HistoryStatus { initial, loading, loaded, error }

class HistoryState extends Equatable {
  final HistoryStatus donationStatus;
  final List<RequestItem> donationRequests;
  final String? donationError;
  final bool donationIsLoadingMore;
  final bool donationHasReachedEnd;
  final int donationCurrentPage;

  final HistoryStatus rentalStatus;
  final List<RequestItem> rentalRequests;
  final String? rentalError;
  final bool rentalIsLoadingMore;
  final bool rentalHasReachedEnd;
  final int rentalCurrentPage;

  const HistoryState({
    this.donationStatus = HistoryStatus.initial,
    this.donationRequests = const [],
    this.donationError,
    this.donationIsLoadingMore = false,
    this.donationHasReachedEnd = false,
    this.donationCurrentPage = 1,
    this.rentalStatus = HistoryStatus.initial,
    this.rentalRequests = const [],
    this.rentalError,
    this.rentalIsLoadingMore = false,
    this.rentalHasReachedEnd = false,
    this.rentalCurrentPage = 1,
  });

  HistoryState copyWith({
    HistoryStatus? donationStatus,
    List<RequestItem>? donationRequests,
    String? donationError,
    bool? donationIsLoadingMore,
    bool? donationHasReachedEnd,
    int? donationCurrentPage,
    HistoryStatus? rentalStatus,
    List<RequestItem>? rentalRequests,
    String? rentalError,
    bool? rentalIsLoadingMore,
    bool? rentalHasReachedEnd,
    int? rentalCurrentPage,
  }) {
    return HistoryState(
      donationStatus: donationStatus ?? this.donationStatus,
      donationRequests: donationRequests ?? this.donationRequests,
      donationError: donationError ?? this.donationError,
      donationIsLoadingMore:
          donationIsLoadingMore ?? this.donationIsLoadingMore,
      donationHasReachedEnd:
          donationHasReachedEnd ?? this.donationHasReachedEnd,
      donationCurrentPage: donationCurrentPage ?? this.donationCurrentPage,
      rentalStatus: rentalStatus ?? this.rentalStatus,
      rentalRequests: rentalRequests ?? this.rentalRequests,
      rentalError: rentalError ?? this.rentalError,
      rentalIsLoadingMore: rentalIsLoadingMore ?? this.rentalIsLoadingMore,
      rentalHasReachedEnd: rentalHasReachedEnd ?? this.rentalHasReachedEnd,
      rentalCurrentPage: rentalCurrentPage ?? this.rentalCurrentPage,
    );
  }

  @override
  List<Object?> get props => [
        donationStatus,
        donationRequests,
        donationError,
        donationIsLoadingMore,
        donationHasReachedEnd,
        donationCurrentPage,
        rentalStatus,
        rentalRequests,
        rentalError,
        rentalIsLoadingMore,
        rentalHasReachedEnd,
        rentalCurrentPage,
      ];
}
