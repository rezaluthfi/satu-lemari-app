import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/features/browse/domain/usecases/analyze_intent_usecase.dart';
import 'package:satulemari/features/browse/domain/usecases/get_ai_suggestions_usecase.dart';
import 'package:satulemari/features/browse/domain/usecases/search_items_usecase.dart';
import 'package:satulemari/features/category_items/domain/entities/item_entity.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

part 'browse_event.dart';
part 'browse_state.dart';

/// Class untuk menyimpan snapshot parameter pencarian
class SearchParamsSnapshot {
  final String query;
  final String? categoryId;
  final String? size;
  final String? color;
  final String? condition;
  final String? sortBy;
  final String? sortOrder;
  final String? city;
  final double? minPrice;
  final double? maxPrice;

  const SearchParamsSnapshot({
    required this.query,
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
}

class BrowseBloc extends Bloc<BrowseEvent, BrowseState> {
  final SearchItemsUseCase searchItems;
  final GetAiSuggestionsUseCase getAiSuggestions;
  final AnalyzeIntentUseCase analyzeIntent;
  StreamSubscription<void>? _searchSubscription;

  BrowseBloc({
    required this.searchItems,
    required this.getAiSuggestions,
    required this.analyzeIntent,
  }) : super(BrowseState.initial()) {
    on<QueryChanged>((event, emit) => emit(state.copyWith(query: event.query)));
    on<BrowseDataFetched>(_onBrowseDataFetched);
    on<TabChanged>(_onTabChanged);
    on<FilterApplied>(_onFilterApplied);
    on<ResetFilters>(_onResetFilters);
    on<SearchTermChanged>(_onSearchTermChanged);
    on<SearchCleared>(_onSearchCleared);
    on<IntentAnalysisAndSearchRequested>(_onIntentAnalysisAndSearchRequested);
    on<SuggestionsRequested>(
      _onSuggestionsRequested,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 300))
          .switchMap(mapper),
    );
  }

  @override
  Future<void> close() {
    _searchSubscription?.cancel();
    return super.close();
  }

  Future<void> _onBrowseDataFetched(
      BrowseDataFetched event, Emitter<BrowseState> emit) async {
    final initialActiveTab = state.activeTab;
    await _performSearch(
        emit,
        state.copyWith(
            activeTab: 'donation', query: '', lastPerformedQuery: ''));
    await _performSearch(emit,
        state.copyWith(activeTab: 'rental', query: '', lastPerformedQuery: ''));
    if (state.activeTab != initialActiveTab) {
      emit(state.copyWith(activeTab: initialActiveTab));
    }
  }

  Future<void> _onTabChanged(
      TabChanged event, Emitter<BrowseState> emit) async {
    _searchSubscription?.cancel();
    _searchSubscription = null;
    final newTab = event.index == 0 ? 'donation' : 'rental';
    if (state.activeTab == newTab) return;

    BrowseState intermediateState;
    final bool hadPriceFilter = state.minPrice != null ||
        state.maxPrice != null ||
        state.sortBy == 'price';

    if (newTab == 'donation' && hadPriceFilter) {
      intermediateState = PriceFilterIgnoredNotification.from(
        state,
        activeTab: newTab,
        minPrice: const Object(),
        maxPrice: const Object(),
        sortBy: state.sortBy == 'price' ? const Object() : null,
        sortOrder: state.sortBy == 'price' ? const Object() : null,
      );
    } else {
      intermediateState = state.copyWith(activeTab: newTab);
    }

    emit(intermediateState);

    // Cek apakah data untuk tab yang dipilih sudah ada dan sesuai dengan filter saat ini
    final shouldRefreshData = _shouldRefreshDataForTab(newTab);

    if (shouldRefreshData) {
      await _performSearch(emit, state);
    }
  }

  /// Menentukan apakah data perlu di-refresh untuk tab yang dipilih
  bool _shouldRefreshDataForTab(String tabType) {
    // Cek apakah query/filter saat ini sama dengan query terakhir yang dijalankan untuk tab tersebut
    final currentSearchParams = _getCurrentSearchParams(tabType);

    if (tabType == 'donation') {
      // Refresh jika belum ada data, status error, atau parameter pencarian berubah
      return state.donationItems.isEmpty ||
          state.donationStatus == BrowseStatus.error ||
          !_isSearchParamsEqual(
              state.lastDonationSearchParams, currentSearchParams);
    } else {
      // Refresh jika belum ada data, status error, atau parameter pencarian berubah
      return state.rentalItems.isEmpty ||
          state.rentalStatus == BrowseStatus.error ||
          !_isSearchParamsEqual(
              state.lastRentalSearchParams, currentSearchParams);
    }
  }

  /// Mendapatkan parameter pencarian saat ini untuk tab tertentu
  SearchParamsSnapshot _getCurrentSearchParams(String tabType) {
    // Untuk tab donasi, abaikan filter harga dan sorting harga
    final minPrice = tabType == 'donation' ? null : state.minPrice;
    final maxPrice = tabType == 'donation' ? null : state.maxPrice;
    final sortBy = (tabType == 'donation' && state.sortBy == 'price')
        ? null
        : state.sortBy;
    final sortOrder = (tabType == 'donation' && state.sortBy == 'price')
        ? null
        : state.sortOrder;

    return SearchParamsSnapshot(
      query: state.query,
      categoryId: state.categoryId,
      size: state.size,
      color: state.color,
      condition: state.condition,
      sortBy: sortBy,
      sortOrder: sortOrder,
      city: state.city,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  /// Membandingkan dua parameter pencarian
  bool _isSearchParamsEqual(SearchParamsSnapshot? a, SearchParamsSnapshot? b) {
    if (a == null || b == null) return false;
    return a.query == b.query &&
        a.categoryId == b.categoryId &&
        a.size == b.size &&
        a.color == b.color &&
        a.condition == b.condition &&
        a.sortBy == b.sortBy &&
        a.sortOrder == b.sortOrder &&
        a.city == b.city &&
        a.minPrice == b.minPrice &&
        a.maxPrice == b.maxPrice;
  }

  Future<void> _onFilterApplied(
      FilterApplied event, Emitter<BrowseState> emit) async {
    _searchSubscription?.cancel();
    final newState = state.copyWith(
      categoryId: event.categoryId,
      size: event.size,
      sortBy: event.sortBy,
      sortOrder: event.sortOrder,
      city: event.city,
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
    );
    await _performSearch(emit, newState);
  }

  Future<void> _onResetFilters(
      ResetFilters event, Emitter<BrowseState> emit) async {
    _searchSubscription?.cancel();
    final newState = BrowseState.initial().copyWith(activeTab: state.activeTab);
    await _performSearch(emit, newState);
  }

  Future<void> _onSearchTermChanged(
      SearchTermChanged event, Emitter<BrowseState> emit) async {
    final newState = state.copyWith(query: event.query);
    await _performSearch(emit, newState);
  }

  Future<void> _onSearchCleared(
      SearchCleared event, Emitter<BrowseState> emit) async {
    _searchSubscription?.cancel();
    final bool wasJustTyping = state.query != state.lastPerformedQuery;

    emit(state.copyWith(
      suggestionStatus: SuggestionStatus.initial,
      suggestions: [],
    ));

    if (wasJustTyping) {
      emit(state.copyWith(query: state.lastPerformedQuery));
    } else {
      final newState = state.copyWith(query: '', lastPerformedQuery: '');
      await _performSearch(emit, newState);
    }
  }

  Future<void> _onIntentAnalysisAndSearchRequested(
    IntentAnalysisAndSearchRequested event,
    Emitter<BrowseState> emit,
  ) async {
    _searchSubscription?.cancel();
    _searchSubscription = null;
    final newState = state.copyWith(
        query: event.query,
        categoryId: null,
        size: null,
        color: null,
        condition: null,
        sortBy: null,
        sortOrder: null,
        city: null,
        minPrice: null,
        maxPrice: null);
    await _performSearch(emit, newState);
  }

  Future<void> _onSuggestionsRequested(
      SuggestionsRequested event, Emitter<BrowseState> emit) async {
    if (event.query.trim().isEmpty) {
      emit(state.copyWith(
          suggestionStatus: SuggestionStatus.initial, suggestions: []));
      return;
    }
    emit(state.copyWith(suggestionStatus: SuggestionStatus.loading));
    final result = await getAiSuggestions(event.query);
    result.fold(
      (failure) => emit(state.copyWith(
          suggestionStatus: SuggestionStatus.error,
          suggestionError: failure.message)),
      (suggestions) => emit(state.copyWith(
          suggestionStatus: SuggestionStatus.success,
          suggestions: suggestions.suggestions)),
    );
  }

  Future<void> _performSearch(
      Emitter<BrowseState> emit, BrowseState currentState) async {
    _searchSubscription?.cancel();

    // Set "memori" setiap kali pencarian dijalankan
    final stateWithMemory =
        currentState.copyWith(lastPerformedQuery: currentState.query);

    final currentTab = stateWithMemory.activeTab;
    if (currentTab == 'donation') {
      emit(stateWithMemory.copyWith(donationStatus: BrowseStatus.loading));
    } else {
      emit(stateWithMemory.copyWith(rentalStatus: BrowseStatus.loading));
    }

    final minPrice = currentTab == 'donation' ? null : stateWithMemory.minPrice;
    final maxPrice = currentTab == 'donation' ? null : stateWithMemory.maxPrice;

    // Untuk tab donasi, abaikan sorting berdasarkan harga
    final sortBy =
        (currentTab == 'donation' && stateWithMemory.sortBy == 'price')
            ? null
            : stateWithMemory.sortBy;
    final sortOrder =
        (currentTab == 'donation' && stateWithMemory.sortBy == 'price')
            ? null
            : stateWithMemory.sortOrder;

    final singleWordQuery = stateWithMemory.query.split(' ').first;

    final params = SearchItemsParams(
      type: currentTab,
      query: singleWordQuery,
      categoryId: stateWithMemory.categoryId,
      size: stateWithMemory.size,
      color: stateWithMemory.color,
      condition: stateWithMemory.condition,
      sortBy: sortBy,
      sortOrder: sortOrder,
      city: stateWithMemory.city,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );

    // Simpan parameter pencarian untuk tab ini
    final searchSnapshot = SearchParamsSnapshot(
      query: stateWithMemory.query,
      categoryId: stateWithMemory.categoryId,
      size: stateWithMemory.size,
      color: stateWithMemory.color,
      condition: stateWithMemory.condition,
      sortBy: sortBy,
      sortOrder: sortOrder,
      city: stateWithMemory.city,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );

    final completer = Completer<void>();
    _searchSubscription = completer.future.asStream().listen(null);
    final result = await searchItems(params);
    if (completer.isCompleted) return;

    // Gunakan state terbaru dari BLoC untuk menghindari menimpa state yang lebih baru
    final latestState = state;

    result.fold(
      (failure) {
        if (currentTab == 'donation') {
          emit(latestState.copyWith(
            donationStatus: BrowseStatus.error,
            donationError: failure.message,
            donationItems: [],
            lastPerformedQuery: stateWithMemory.lastPerformedQuery,
            lastDonationSearchParams: searchSnapshot,
          ));
        } else {
          emit(latestState.copyWith(
            rentalStatus: BrowseStatus.error,
            rentalError: failure.message,
            rentalItems: [],
            lastPerformedQuery: stateWithMemory.lastPerformedQuery,
            lastRentalSearchParams: searchSnapshot,
          ));
        }
      },
      (items) {
        if (currentTab == 'donation') {
          emit(latestState.copyWith(
            donationStatus: BrowseStatus.success,
            donationItems: items,
            lastPerformedQuery: stateWithMemory.lastPerformedQuery,
            lastDonationSearchParams: searchSnapshot,
          ));
        } else {
          emit(latestState.copyWith(
            rentalStatus: BrowseStatus.success,
            rentalItems: items,
            lastPerformedQuery: stateWithMemory.lastPerformedQuery,
            lastRentalSearchParams: searchSnapshot,
          ));
        }
      },
    );
    if (!completer.isCompleted) {
      completer.complete();
    }
  }
}
