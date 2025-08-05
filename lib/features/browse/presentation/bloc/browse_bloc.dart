import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/features/browse/domain/usecases/analyze_intent_usecase.dart';
import 'package:satulemari/features/browse/domain/usecases/get_ai_suggestions_usecase.dart';
import 'package:satulemari/features/browse/domain/usecases/search_items_usecase.dart';
import 'package:satulemari/features/category_items/domain/entities/item_entity.dart';
import 'package:satulemari/features/browse/domain/entities/intent_analysis.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

part 'browse_event.dart';
part 'browse_state.dart';

class SearchParamsSnapshot extends Equatable {
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

  @override
  List<Object?> get props => [
        query,
        categoryId,
        size,
        color,
        condition,
        sortBy,
        sortOrder,
        city,
        minPrice,
        maxPrice
      ];
}

class BrowseBloc extends Bloc<BrowseEvent, BrowseState> {
  final SearchItemsUseCase searchItems;
  final GetAiSuggestionsUseCase getAiSuggestions;
  final AnalyzeIntentUseCase analyzeIntent;

  BrowseBloc({
    required this.searchItems,
    required this.getAiSuggestions,
    required this.analyzeIntent,
  }) : super(BrowseState.initial()) {
    on<QueryChanged>((event, emit) {
      if (state.query != event.query) {
        emit(state.copyWith(query: event.query));
      }
    });
    on<BrowseDataFetched>(_onBrowseDataFetched,
        transformer: (events, mapper) => events.switchMap(mapper));
    on<TabChanged>(_onTabChanged);
    on<FilterApplied>(_onFilterApplied,
        transformer: (events, mapper) => events.switchMap(mapper));
    on<ResetFilters>(_onResetFilters,
        transformer: (events, mapper) => events.switchMap(mapper));
    on<SearchTermChanged>(_onSearchTermChanged,
        transformer: (events, mapper) => events.switchMap(mapper));
    on<SearchCleared>(_onSearchCleared);
    on<IntentAnalysisAndSearchRequested>(_onIntentAnalysisAndSearchRequested,
        transformer: (events, mapper) => events.switchMap(mapper));
    on<SuggestionsRequested>(
      _onSuggestionsRequested,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 300))
          .switchMap(mapper),
    );
    on<NotificationCleared>((event, emit) => emit(state.clearNotification()));
  }

  @override
  Future<void> close() {
    return super.close();
  }

  Future<void> _onTabChanged(
      TabChanged event, Emitter<BrowseState> emit) async {
    final newTab = event.index == 0 ? 'donation' : 'rental';
    if (state.activeTab == newTab) return;

    final bool hadPriceFilter = state.minPrice != null ||
        state.maxPrice != null ||
        state.sortBy == 'price';

    if (newTab == 'donation' && hadPriceFilter) {
      emit(state.copyWith(
        activeTab: newTab,
        notification: PriceFilterIgnoredNotification(),
      ));
    } else {
      emit(state.copyWith(activeTab: newTab));
    }
  }

  Future<void> _onSearchCleared(
      SearchCleared event, Emitter<BrowseState> emit) async {
    // Always reset to initial state when clear button is pressed
    final cleanState = BrowseState.initial().copyWith(
      activeTab: state.activeTab,
      isFromSpeechToText: false,
      // Set loading states immediately for both tabs
      donationStatus: BrowseStatus.loading,
      rentalStatus: BrowseStatus.loading,
    );
    emit(cleanState);
    await _performSearchForAllTabs(emit, cleanState);
  }

  // PERBAIKAN #1: Saat menghapus filter, gunakan `lastPerformedQuery` yang sudah ada.
  Future<void> _onFilterApplied(
      FilterApplied event, Emitter<BrowseState> emit) async {
    final newState = state.copyWith(
      categoryId: event.categoryId,
      size: event.size,
      sortBy: event.sortBy,
      sortOrder: event.sortOrder,
      city: event.city,
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
      // Gunakan `lastPerformedQuery` dari state saat ini, bukan `state.query` yang mungkin kalimat panjang.
      lastPerformedQuery: state.lastPerformedQuery,
      isFromSpeechToText:
          false, // Manual filter application clears speech-to-text flag
      // Set loading states immediately for both tabs
      donationStatus: BrowseStatus.loading,
      rentalStatus: BrowseStatus.loading,
    );

    emit(newState);
    await _performSearchForAllTabs(emit, newState);
  }

  // PERBAIKAN #2: Pencarian manual baru harus me-reset semua filter lama.
  Future<void> _onSearchTermChanged(
      SearchTermChanged event, Emitter<BrowseState> emit) async {
    // Mulai dari state bersih, hanya bawa tab aktif dan query baru.
    final newState = BrowseState.initial().copyWith(
        activeTab: state.activeTab,
        query: event.query,
        lastPerformedQuery: event.query,
        isFromSpeechToText: false, // Manual search clears speech-to-text flag
        // Set loading states immediately for both tabs
        donationStatus: BrowseStatus.loading,
        rentalStatus: BrowseStatus.loading);
    // Emit loading state first, then perform search
    emit(newState);
    await _performSearchForAllTabs(emit, newState);
  }

  Future<void> _onIntentAnalysisAndSearchRequested(
    IntentAnalysisAndSearchRequested event,
    Emitter<BrowseState> emit,
  ) async {
    emit(state.copyWith(
      query: event.query,
      suggestionStatus: SuggestionStatus.loading,
      // Set loading states immediately for both tabs during AI analysis
      donationStatus: BrowseStatus.loading,
      rentalStatus: BrowseStatus.loading,
    ));

    add(SuggestionsRequested(event.query));

    final result = await analyzeIntent(event.query);

    await result.fold(
      (failure) async {
        final stateWithFallbackSearch = state.copyWith(
          lastPerformedQuery: event.query,
        );
        await _performSearchForAllTabs(emit, stateWithFallbackSearch);
      },
      (intentAnalysis) async {
        final filters = intentAnalysis.filters;
        final stateWithAiFilters = state.copyWith(
          query: intentAnalysis.originalQuery,
          lastPerformedQuery: filters.search ?? intentAnalysis.originalQuery,
          // Apply AI filters directly, don't fall back to existing state
          categoryId: filters.categoryId,
          size: filters.size,
          color: filters.color,
          condition: filters.condition,
          maxPrice: filters.maxPrice?.toDouble(),
          isFromSpeechToText:
              true, // Mark filters as coming from speech-to-text
        );
        // Emit the state with filters first so UI can show them
        emit(stateWithAiFilters);
        await _performSearchForAllTabs(emit, stateWithAiFilters);
      },
    );
  }

  Future<void> _onResetFilters(
      ResetFilters event, Emitter<BrowseState> emit) async {
    final cleanState = BrowseState.initial().copyWith(
        activeTab: state.activeTab,
        isFromSpeechToText: false, // Reset clears speech-to-text flag
        // Set loading states immediately for both tabs
        donationStatus: BrowseStatus.loading,
        rentalStatus: BrowseStatus.loading);
    emit(cleanState);
    await _performSearchForAllTabs(emit, cleanState);
  }

  Future<void> _performSearchForAllTabs(
      Emitter<BrowseState> emit, BrowseState currentState) async {
    // PERBAIKAN: Proses kedua tab secara bersamaan untuk responsivitas yang optimal
    await Future.wait([
      _performSearch(emit, currentState, 'donation'),
      _performSearch(emit, currentState, 'rental'),
    ]);
  }

  // PERBAIKAN #3: Logika anti-race condition yang lebih solid.
  Future<void> _performSearch(Emitter<BrowseState> emit,
      BrowseState currentState, String targetTab) async {
    final queryForSearch = currentState.lastPerformedQuery.isNotEmpty
        ? currentState.lastPerformedQuery
        : currentState.query;

    // Use the passed currentState as base, then update with loading status
    emit(targetTab == 'donation'
        ? currentState.copyWith(donationStatus: BrowseStatus.loading)
        : currentState.copyWith(rentalStatus: BrowseStatus.loading));

    final params = SearchItemsParams(
      type: targetTab,
      query: queryForSearch,
      categoryId: currentState.categoryId,
      size: currentState.size,
      color: currentState.color,
      condition: currentState.condition,
      sortBy: (targetTab == 'donation' && currentState.sortBy == 'price')
          ? null
          : currentState.sortBy,
      sortOrder: (targetTab == 'donation' && currentState.sortBy == 'price')
          ? null
          : currentState.sortOrder,
      city: currentState.city,
      minPrice: targetTab == 'donation' ? null : currentState.minPrice,
      maxPrice: targetTab == 'donation' ? null : currentState.maxPrice,
    );

    final searchSnapshot = SearchParamsSnapshot(
      query: queryForSearch,
      categoryId: params.categoryId,
      size: params.size,
      color: params.color,
      condition: params.condition,
      sortBy: params.sortBy,
      sortOrder: params.sortOrder,
      city: params.city,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
    );

    final result = await searchItems(params);

    result.fold(
      (failure) {
        // Use the current BLoC state as base to preserve other tab's data
        final latestBlocState = state;
        if (targetTab == 'donation') {
          emit(latestBlocState.copyWith(
            donationStatus: BrowseStatus.error,
            donationError: failure.message,
            donationItems: [],
            lastDonationSearchParams: searchSnapshot,
          ));
        } else {
          emit(latestBlocState.copyWith(
            rentalStatus: BrowseStatus.error,
            rentalError: failure.message,
            rentalItems: [],
            lastRentalSearchParams: searchSnapshot,
          ));
        }
      },
      (items) {
        // Use the current BLoC state as base to preserve other tab's data
        final latestBlocState = state;
        if (targetTab == 'donation') {
          emit(latestBlocState.copyWith(
            donationStatus: BrowseStatus.success,
            donationItems: items,
            lastDonationSearchParams: searchSnapshot,
          ));
        } else {
          emit(latestBlocState.copyWith(
            rentalStatus: BrowseStatus.success,
            rentalItems: items,
            lastRentalSearchParams: searchSnapshot,
          ));
        }
      },
    );
  }

  Future<void> _onBrowseDataFetched(
      BrowseDataFetched event, Emitter<BrowseState> emit) async {
    // Set loading states for initial data fetch
    final loadingState = state.copyWith(
      donationStatus: BrowseStatus.loading,
      rentalStatus: BrowseStatus.loading,
    );
    emit(loadingState);
    await _performSearchForAllTabs(emit, loadingState);
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
}
