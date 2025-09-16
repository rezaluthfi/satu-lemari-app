part of 'browse_bloc.dart';

abstract class BrowseNotification extends Equatable {
  const BrowseNotification();
  @override
  List<Object?> get props => [];
}

class PriceFilterIgnoredNotification extends BrowseNotification {}

enum BrowseStatus { initial, loading, success, error }

enum SuggestionStatus { initial, loading, success, error }

class BrowseState extends Equatable {
  // Status umum untuk feedback UI
  final BrowseStatus status;

  // Data dan status terpisah untuk setiap tab
  final BrowseStatus donationStatus;
  final List<Item> donationItems;
  final String? donationError;
  final bool donationIsLoadingMore;
  final bool donationHasReachedEnd;
  final int donationCurrentPage;

  final BrowseStatus rentalStatus;
  final List<Item> rentalItems;
  final String? rentalError;
  final bool rentalIsLoadingMore;
  final bool rentalHasReachedEnd;
  final int rentalCurrentPage;

  final BrowseStatus thriftingStatus;
  final List<Item> thriftingItems;
  final String? thriftingError;
  final bool thriftingIsLoadingMore;
  final bool thriftingHasReachedEnd;
  final int thriftingCurrentPage;

  // Tab yang sedang aktif
  final String activeTab; // 'donation', 'rental', or 'thrifting'

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

  // Menyimpan parameter pencarian terakhir untuk setiap tab
  final SearchParamsSnapshot? lastDonationSearchParams;
  final SearchParamsSnapshot? lastRentalSearchParams;
  final SearchParamsSnapshot? lastThriftingSearchParams;

  // Properti notifikasi baru
  final BrowseNotification? notification;

  // Flag untuk melacak apakah filter saat ini berasal dari speech-to-text
  final bool isFromSpeechToText;

  const BrowseState({
    this.status = BrowseStatus.initial,
    this.donationStatus = BrowseStatus.initial,
    this.donationItems = const [],
    this.donationError,
    this.donationIsLoadingMore = false,
    this.donationHasReachedEnd = false,
    this.donationCurrentPage = 1,
    this.rentalStatus = BrowseStatus.initial,
    this.rentalItems = const [],
    this.rentalError,
    this.rentalIsLoadingMore = false,
    this.rentalHasReachedEnd = false,
    this.rentalCurrentPage = 1,
    this.thriftingStatus = BrowseStatus.initial,
    this.thriftingItems = const [],
    this.thriftingError,
    this.thriftingIsLoadingMore = false,
    this.thriftingHasReachedEnd = false,
    this.thriftingCurrentPage = 1,
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
    this.lastDonationSearchParams,
    this.lastRentalSearchParams,
    this.lastThriftingSearchParams, // <-- TAMBAHAN
    this.notification,
    this.isFromSpeechToText = false,
  });

  factory BrowseState.initial() {
    return const BrowseState();
  }

  BrowseState copyWith({
    BrowseStatus? status,
    BrowseStatus? donationStatus,
    List<Item>? donationItems,
    String? donationError,
    bool? donationIsLoadingMore,
    bool? donationHasReachedEnd,
    int? donationCurrentPage,
    BrowseStatus? rentalStatus,
    List<Item>? rentalItems,
    String? rentalError,
    bool? rentalIsLoadingMore,
    bool? rentalHasReachedEnd,
    int? rentalCurrentPage,
    BrowseStatus? thriftingStatus,
    List<Item>? thriftingItems,
    String? thriftingError,
    bool? thriftingIsLoadingMore,
    bool? thriftingHasReachedEnd,
    int? thriftingCurrentPage,
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
    SearchParamsSnapshot? lastDonationSearchParams,
    SearchParamsSnapshot? lastRentalSearchParams,
    SearchParamsSnapshot? lastThriftingSearchParams,
    Object? notification = _notProvided,
    bool? isFromSpeechToText,
  }) {
    return BrowseState(
      status: status ?? this.status,
      donationStatus: donationStatus ?? this.donationStatus,
      donationItems: donationItems ?? this.donationItems,
      donationError: donationError ?? this.donationError,
      donationIsLoadingMore:
          donationIsLoadingMore ?? this.donationIsLoadingMore,
      donationHasReachedEnd:
          donationHasReachedEnd ?? this.donationHasReachedEnd,
      donationCurrentPage: donationCurrentPage ?? this.donationCurrentPage,
      rentalStatus: rentalStatus ?? this.rentalStatus,
      rentalItems: rentalItems ?? this.rentalItems,
      rentalError: rentalError ?? this.rentalError,
      rentalIsLoadingMore: rentalIsLoadingMore ?? this.rentalIsLoadingMore,
      rentalHasReachedEnd: rentalHasReachedEnd ?? this.rentalHasReachedEnd,
      rentalCurrentPage: rentalCurrentPage ?? this.rentalCurrentPage,
      thriftingStatus: thriftingStatus ?? this.thriftingStatus,
      thriftingItems: thriftingItems ?? this.thriftingItems,
      thriftingError: thriftingError ?? this.thriftingError,
      thriftingIsLoadingMore:
          thriftingIsLoadingMore ?? this.thriftingIsLoadingMore,
      thriftingHasReachedEnd:
          thriftingHasReachedEnd ?? this.thriftingHasReachedEnd,
      thriftingCurrentPage: thriftingCurrentPage ?? this.thriftingCurrentPage,
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
      lastDonationSearchParams:
          lastDonationSearchParams ?? this.lastDonationSearchParams,
      lastRentalSearchParams:
          lastRentalSearchParams ?? this.lastRentalSearchParams,
      lastThriftingSearchParams:
          lastThriftingSearchParams ?? this.lastThriftingSearchParams,
      notification: _copyWith(notification, this.notification),
      isFromSpeechToText: isFromSpeechToText ?? this.isFromSpeechToText,
    );
  }

  BrowseState clearNotification() {
    return copyWith(notification: null);
  }

  @override
  List<Object?> get props => [
        status,
        donationStatus,
        donationItems,
        donationError,
        donationIsLoadingMore,
        donationHasReachedEnd,
        donationCurrentPage,
        rentalStatus,
        rentalItems,
        rentalError,
        rentalIsLoadingMore,
        rentalHasReachedEnd,
        rentalCurrentPage,
        thriftingStatus,
        thriftingItems,
        thriftingError,
        thriftingIsLoadingMore,
        thriftingHasReachedEnd,
        thriftingCurrentPage,
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
        lastDonationSearchParams,
        lastRentalSearchParams,
        lastThriftingSearchParams,
        notification,
        isFromSpeechToText,
      ];
}

const Object _notProvided = Object();

T? _copyWith<T>(Object? value, T? fallback) {
  if (value == _notProvided) {
    return fallback;
  }
  return value as T?;
}
