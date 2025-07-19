part of 'history_bloc.dart';

enum HistoryStatus { initial, loading, loaded, error }

class HistoryState extends Equatable {
  final HistoryStatus donationStatus;
  final List<RequestItem> donationRequests;
  final String? donationError;

  final HistoryStatus rentalStatus;
  final List<RequestItem> rentalRequests;
  final String? rentalError;

  const HistoryState({
    this.donationStatus = HistoryStatus.initial,
    this.donationRequests = const [],
    this.donationError,
    this.rentalStatus = HistoryStatus.initial,
    this.rentalRequests = const [],
    this.rentalError,
  });

  HistoryState copyWith({
    HistoryStatus? donationStatus,
    List<RequestItem>? donationRequests,
    String? donationError,
    HistoryStatus? rentalStatus,
    List<RequestItem>? rentalRequests,
    String? rentalError,
  }) {
    return HistoryState(
      donationStatus: donationStatus ?? this.donationStatus,
      donationRequests: donationRequests ?? this.donationRequests,
      donationError: donationError ?? this.donationError,
      rentalStatus: rentalStatus ?? this.rentalStatus,
      rentalRequests: rentalRequests ?? this.rentalRequests,
      rentalError: rentalError ?? this.rentalError,
    );
  }

  @override
  List<Object?> get props => [
        donationStatus,
        donationRequests,
        donationError,
        rentalStatus,
        rentalRequests,
        rentalError
      ];
}
