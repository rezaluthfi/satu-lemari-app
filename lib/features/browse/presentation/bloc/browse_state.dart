part of 'browse_bloc.dart';

enum BrowseStatus { initial, loading, success, error }

class BrowseState extends Equatable {
  // Status umum untuk feedback UI
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

  final String query;
  final String? categoryId;
  final String? size;
  final String? sortBy;
  final String? sortOrder;
  final String? city;
  final double? minPrice;
  final double? maxPrice;

  const BrowseState({
    this.status = BrowseStatus.initial,
    this.donationStatus = BrowseStatus.initial,
    this.donationItems = const [],
    this.donationError,
    this.rentalStatus = BrowseStatus.initial,
    this.rentalItems = const [],
    this.rentalError,
    this.activeTab = 'donation',
    // --- MODIFIKASI: Tambahkan di constructor ---
    this.query = '',
    this.categoryId,
    this.size,
    this.sortBy,
    this.sortOrder,
    this.city,
    this.minPrice,
    this.maxPrice,
  });

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
    // --- MODIFIKASI: Gunakan helper _copyWith untuk nullable fields ---
    Object? categoryId = _notProvided,
    Object? size = _notProvided,
    Object? sortBy = _notProvided,
    Object? sortOrder = _notProvided,
    Object? city = _notProvided,
    Object? minPrice = _notProvided,
    Object? maxPrice = _notProvided,
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
      // --- MODIFIKASI: Gunakan helper untuk semua properti filter ---
      categoryId: _copyWith(categoryId, this.categoryId),
      size: _copyWith(size, this.size),
      sortBy: _copyWith(sortBy, this.sortBy),
      sortOrder: _copyWith(sortOrder, this.sortOrder),
      city: _copyWith(city, this.city),
      minPrice: _copyWith(minPrice, this.minPrice),
      maxPrice: _copyWith(maxPrice, this.maxPrice),
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
        // --- MODIFIKASI: Tambahkan semua properti filter ke props ---
        query,
        categoryId,
        size,
        sortBy,
        sortOrder,
        city,
        minPrice,
        maxPrice,
      ];
}

// Helper object untuk membedakan antara null dan tidak disediakan
const Object _notProvided = Object();

// Helper function untuk copyWith yang lebih bersih
T? _copyWith<T>(Object? value, T? fallback) {
  if (value == _notProvided) {
    return fallback;
  }
  return value as T?;
}
