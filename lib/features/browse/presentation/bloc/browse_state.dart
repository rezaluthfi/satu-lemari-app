part of 'browse_bloc.dart';

// PERBAIKAN: Sistem notifikasi baru yang lebih andal
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

  // Menyimpan parameter pencarian terakhir untuk setiap tab
  final SearchParamsSnapshot? lastDonationSearchParams;
  final SearchParamsSnapshot? lastRentalSearchParams;

  // PERBAIKAN: Properti notifikasi baru
  final BrowseNotification? notification;

  // Flag untuk melacak apakah filter saat ini berasal dari speech-to-text
  final bool isFromSpeechToText;

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
    this.lastDonationSearchParams,
    this.lastRentalSearchParams,
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
    SearchParamsSnapshot? lastDonationSearchParams,
    SearchParamsSnapshot? lastRentalSearchParams,
    Object? notification = _notProvided,
    bool? isFromSpeechToText,
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
      lastDonationSearchParams:
          lastDonationSearchParams ?? this.lastDonationSearchParams,
      lastRentalSearchParams:
          lastRentalSearchParams ?? this.lastRentalSearchParams,
      notification: _copyWith(notification, this.notification),
      isFromSpeechToText: isFromSpeechToText ?? this.isFromSpeechToText,
    );
  }

  // Helper untuk membersihkan notifikasi
  BrowseState clearNotification() {
    return copyWith(notification: null);
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
        lastDonationSearchParams,
        lastRentalSearchParams,
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
