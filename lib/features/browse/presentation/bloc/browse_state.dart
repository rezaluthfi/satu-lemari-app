part of 'browse_bloc.dart';

enum BrowseStatus { initial, loading, success, error }

class BrowseState extends Equatable {
  // Status umum untuk feedback UI (misal: saat refresh)
  final BrowseStatus status;

  // Data dan status terpisah untuk setiap tab
  final BrowseStatus donationStatus;
  final List<Item> donationItems;
  final String? donationError;

  final BrowseStatus rentalStatus;
  final List<Item> rentalItems;
  final String? rentalError;

  // Tab yang sedang aktif
  final String activeTab; // 'donation' or 'rental'

  // Parameter filter & pencarian
  final String query;
  final String? categoryId;
  final String? size;

  const BrowseState({
    this.status = BrowseStatus.initial,
    this.donationStatus = BrowseStatus.initial,
    this.donationItems = const [],
    this.donationError,
    this.rentalStatus = BrowseStatus.initial,
    this.rentalItems = const [],
    this.rentalError,
    this.activeTab = 'donation',
    this.query = '',
    this.categoryId,
    this.size,
  });

  // State awal
  factory BrowseState.initial() {
    return const BrowseState();
  }

  BrowseState copyWith({
    BrowseStatus? status,
    BrowseStatus? donationStatus,
    List<Item>? donationItems,
    String? donationError,
    BrowseStatus? rentalStatus,
    List<Item>? rentalItems,
    String? rentalError,
    String? activeTab,
    String? query,
    Object? categoryId = _notProvided,
    Object? size = _notProvided,
  }) {
    return BrowseState(
      status: status ?? this.status,
      donationStatus: donationStatus ?? this.donationStatus,
      donationItems: donationItems ?? this.donationItems,
      donationError: donationError ?? this.donationError,
      rentalStatus: rentalStatus ?? this.rentalStatus,
      rentalItems: rentalItems ?? this.rentalItems,
      rentalError: rentalError ?? this.rentalError,
      activeTab: activeTab ?? this.activeTab,
      query: query ?? this.query,
      categoryId:
          categoryId == _notProvided ? this.categoryId : categoryId as String?,
      size: size == _notProvided ? this.size : size as String?,
    );
  }

  @override
  List<Object?> get props => [
        status,
        donationStatus,
        donationItems,
        donationError,
        rentalStatus,
        rentalItems,
        rentalError,
        activeTab,
        query,
        categoryId,
        size
      ];
}

// Helper object to distinguish between null and not provided
const Object _notProvided = Object();
