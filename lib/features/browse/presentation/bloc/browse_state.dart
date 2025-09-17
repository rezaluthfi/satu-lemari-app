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
  // Status umum untuk feedback UI, terutama untuk fetch awal
  final BrowseStatus status;

  // Data dan status terpisah untuk setiap kategori item
  final List<Item> donationItems;
  final List<Item> rentalItems;
  final List<Item> thriftingItems;
  final String? error; // Satu error message untuk semua

  // Status untuk pagination (jika diperlukan di masa depan)
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final int currentPage;

  // Filter tipe yang sedang aktif
  final String selectedType; // 'all', 'donation', 'rental', 'thrifting'

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

  // Menyimpan parameter pencarian terakhir
  final SearchParamsSnapshot? lastSearchParams;

  // Properti notifikasi
  final BrowseNotification? notification;

  // Flag untuk melacak apakah filter saat ini berasal dari speech-to-text
  final bool isFromSpeechToText;

  const BrowseState({
    this.status = BrowseStatus.initial,
    this.donationItems = const [],
    this.rentalItems = const [],
    this.thriftingItems = const [],
    this.error,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.currentPage = 1,
    this.selectedType = 'all',
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
    this.lastSearchParams,
    this.notification,
    this.isFromSpeechToText = false,
  });

  factory BrowseState.initial() {
    return const BrowseState();
  }

  BrowseState copyWith({
    BrowseStatus? status,
    List<Item>? donationItems,
    List<Item>? rentalItems,
    List<Item>? thriftingItems,
    String? error,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    int? currentPage,
    String? selectedType,
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
    SearchParamsSnapshot? lastSearchParams,
    Object? notification = _notProvided,
    bool? isFromSpeechToText,
  }) {
    return BrowseState(
      status: status ?? this.status,
      donationItems: donationItems ?? this.donationItems,
      rentalItems: rentalItems ?? this.rentalItems,
      thriftingItems: thriftingItems ?? this.thriftingItems,
      error: error ?? this.error,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      currentPage: currentPage ?? this.currentPage,
      selectedType: selectedType ?? this.selectedType,
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
      lastSearchParams: lastSearchParams ?? this.lastSearchParams,
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
        donationItems,
        rentalItems,
        thriftingItems,
        error,
        isLoadingMore,
        hasReachedEnd,
        currentPage,
        selectedType,
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
        lastSearchParams,
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
