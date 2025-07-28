part of 'browse_bloc.dart';

enum BrowseStatus { initial, loading, success, error }

enum SuggestionStatus { initial, loading, success, error }

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

  // Properti untuk AI Suggestions
  final SuggestionStatus suggestionStatus;
  final List<String> suggestions;
  final String? suggestionError;

  // Properti untuk filter dan pencarian
  final String query;
  final String lastPerformedQuery; // Menyimpan query terakhir yang dieksekusi
  final String? categoryId;
  final String? size;
  final String? color;
  final String? condition;
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
    this.suggestionStatus = SuggestionStatus.initial,
    this.suggestions = const [],
    this.suggestionError,
    this.query = '',
    this.lastPerformedQuery = '',
    this.categoryId,
    this.size,
    this.color,
    this.condition,
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
    SuggestionStatus? suggestionStatus,
    List<String>? suggestions,
    String? suggestionError,
    String? query,
    String? lastPerformedQuery,
    Object? categoryId = _notProvided,
    Object? size = _notProvided,
    Object? color = _notProvided,
    Object? condition = _notProvided,
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
      suggestionStatus: suggestionStatus ?? this.suggestionStatus,
      suggestions: suggestions ?? this.suggestions,
      suggestionError: suggestionError ?? this.suggestionError,
      query: query ?? this.query,
      lastPerformedQuery: lastPerformedQuery ?? this.lastPerformedQuery,
      categoryId: _copyWith(categoryId, this.categoryId),
      size: _copyWith(size, this.size),
      color: _copyWith(color, this.color),
      condition: _copyWith(condition, this.condition),
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
        suggestionStatus,
        suggestions,
        suggestionError,
        query,
        lastPerformedQuery,
        categoryId,
        size,
        color,
        condition,
        sortBy,
        sortOrder,
        city,
        minPrice,
        maxPrice,
      ];
}

const Object _notProvided = Object();

T? _copyWith<T>(Object? value, T? fallback) {
  if (value == _notProvided) {
    return fallback;
  }
  return value as T?;
}

class PriceFilterIgnoredNotification extends BrowseState {
  const PriceFilterIgnoredNotification({
    required super.donationStatus,
    required super.donationItems,
    super.donationError,
    required super.rentalStatus,
    required super.rentalItems,
    super.rentalError,
    required super.activeTab,
    required super.suggestionStatus,
    required super.suggestions,
    super.suggestionError,
    required super.query,
    required super.lastPerformedQuery,
    super.categoryId,
    super.size,
    super.color,
    super.condition,
    super.sortBy,
    super.sortOrder,
    super.city,
    super.minPrice,
    super.maxPrice,
  });

  factory PriceFilterIgnoredNotification.from(
    BrowseState state, {
    required String activeTab,
    Object? minPrice,
    Object? maxPrice,
    Object? sortBy,
    Object? sortOrder,
  }) {
    return PriceFilterIgnoredNotification(
      donationStatus: state.donationStatus,
      donationItems: state.donationItems,
      donationError: state.donationError,
      rentalStatus: state.rentalStatus,
      rentalItems: state.rentalItems,
      rentalError: state.rentalError,
      activeTab: activeTab,
      suggestionStatus: state.suggestionStatus,
      suggestions: state.suggestions,
      suggestionError: state.suggestionError,
      query: state.query,
      lastPerformedQuery: state.lastPerformedQuery,
      categoryId: state.categoryId,
      size: state.size,
      color: state.color,
      condition: state.condition,
      city: state.city,
      minPrice: _copyWith(minPrice, state.minPrice),
      maxPrice: _copyWith(maxPrice, state.maxPrice),
      sortBy: _copyWith(sortBy, state.sortBy),
      sortOrder: _copyWith(sortOrder, state.sortOrder),
    );
  }
}
