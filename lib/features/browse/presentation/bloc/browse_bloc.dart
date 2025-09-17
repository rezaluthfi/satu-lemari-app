import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/features/browse/domain/usecases/analyze_intent_usecase.dart';
import 'package:satulemari/features/browse/domain/usecases/get_ai_suggestions_usecase.dart';
import 'package:satulemari/features/browse/domain/usecases/search_items_usecase.dart';
import 'package:satulemari/features/category_items/domain/entities/item_entity.dart';
import 'package:satulemari/features/home/domain/entities/recommendation.dart'; // Impor untuk enum ItemType
import 'package:rxdart/rxdart.dart';

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
    on<FilterTypeSelected>(_onFilterTypeSelected);
    on<FilterApplied>(_onFilterApplied,
        transformer: (events, mapper) => events.switchMap(mapper));
    on<ResetFilters>(_onResetFilters,
        transformer: (events, mapper) => events.switchMap(mapper));
    on<SearchTermChanged>(_onSearchTermChanged,
        transformer: (events, mapper) => events.switchMap(mapper));
    on<SearchCleared>(_onSearchCleared,
        transformer: (events, mapper) => events.switchMap(mapper));
    on<IntentAnalysisAndSearchRequested>(_onIntentAnalysisAndSearchRequested,
        transformer: (events, mapper) => events.switchMap(mapper));
    on<SuggestionsRequested>(
      _onSuggestionsRequested,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 300))
          .switchMap(mapper),
    );
    on<NotificationCleared>((event, emit) => emit(state.clearNotification()));
    on<LoadMoreItems>(_onLoadMoreItems);
    on<RefreshItems>(_onRefreshItems);
  }

  Future<void> _onFilterTypeSelected(
      FilterTypeSelected event, Emitter<BrowseState> emit) async {
    final newType = event.type;
    if (state.selectedType == newType) return;

    final bool hadPriceFilter = state.minPrice != null ||
        state.maxPrice != null ||
        state.sortBy == 'price';

    if (newType == 'donation' && hadPriceFilter) {
      emit(state.copyWith(
        selectedType: newType,
        notification: PriceFilterIgnoredNotification(),
      ));
    } else {
      emit(state.copyWith(selectedType: newType));
    }
  }

  Future<void> _onSearchCleared(
      SearchCleared event, Emitter<BrowseState> emit) async {
    final cleanState = BrowseState.initial().copyWith(
      selectedType: 'all',
      status: BrowseStatus.loading,
    );
    emit(cleanState);
    await _performSearch(emit, cleanState);
  }

  Future<void> _onFilterApplied(
      FilterApplied event, Emitter<BrowseState> emit) async {
    final newState = state.copyWith(
      selectedType: 'all',
      categoryId: event.categoryId,
      size: event.size,
      sortBy: event.sortBy,
      sortOrder: event.sortOrder,
      city: event.city,
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
      isFromSpeechToText: false,
      status: BrowseStatus.loading,
    );
    emit(newState);
    await _performSearch(emit, newState);
  }

  Future<void> _onSearchTermChanged(
      SearchTermChanged event, Emitter<BrowseState> emit) async {
    final newState = BrowseState.initial().copyWith(
        selectedType: 'all',
        query: event.query,
        lastPerformedQuery: event.query,
        status: BrowseStatus.loading);
    emit(newState);
    await _performSearch(emit, newState);
  }

  Future<void> _onIntentAnalysisAndSearchRequested(
    IntentAnalysisAndSearchRequested event,
    Emitter<BrowseState> emit,
  ) async {
    emit(state.copyWith(
      query: event.query,
      suggestionStatus: SuggestionStatus.loading,
      status: BrowseStatus.loading,
    ));

    add(SuggestionsRequested(event.query));

    final result = await analyzeIntent(event.query);

    await result.fold(
      (failure) async {
        final stateWithFallbackSearch = state.copyWith(
          lastPerformedQuery: event.query,
        );
        await _performSearch(emit, stateWithFallbackSearch);
      },
      (intentAnalysis) async {
        final filters = intentAnalysis.filters;
        final stateWithAiFilters = state.copyWith(
          query: intentAnalysis.originalQuery,
          lastPerformedQuery: filters.search ?? intentAnalysis.originalQuery,
          categoryId: filters.categoryId,
          size: filters.size,
          color: filters.color,
          condition: filters.condition,
          maxPrice: filters.maxPrice?.toDouble(),
          isFromSpeechToText: true,
          selectedType: 'all',
        );
        emit(stateWithAiFilters);
        await _performSearch(emit, stateWithAiFilters);
      },
    );
  }

  Future<void> _onResetFilters(
      ResetFilters event, Emitter<BrowseState> emit) async {
    final cleanState = BrowseState.initial().copyWith(
      selectedType: 'all',
      status: BrowseStatus.loading,
    );
    emit(cleanState);
    await _performSearch(emit, cleanState);
  }

  Future<void> _onBrowseDataFetched(
      BrowseDataFetched event, Emitter<BrowseState> emit) async {
    emit(state.copyWith(status: BrowseStatus.loading));
    await _performSearch(emit, state);
  }

  Future<void> _performSearch(
      Emitter<BrowseState> emit, BrowseState currentState,
      {bool isLoadMore = false}) async {
    final pageToFetch = isLoadMore ? currentState.currentPage + 1 : 1;
    final queryForSearch = currentState.lastPerformedQuery.isNotEmpty
        ? currentState.lastPerformedQuery
        : currentState.query;

    final params = SearchItemsParams(
      type: null, // Always fetch all types from API
      query: queryForSearch,
      categoryId: currentState.categoryId,
      size: currentState.size,
      color: currentState.color,
      condition: currentState.condition,
      sortBy: currentState.sortBy,
      sortOrder: currentState.sortOrder,
      city: currentState.city,
      minPrice: currentState.minPrice,
      maxPrice: currentState.maxPrice,
      page: pageToFetch,
      limit: 10,
    );

    final result = await searchItems(params);

    result.fold(
      (failure) {
        emit(currentState.copyWith(
          status: BrowseStatus.error,
          error: failure.message,
          isLoadingMore: false,
        ));
      },
      (newItems) {
        // Pisahkan item berdasarkan enum ItemType
        final newDonationItems =
            newItems.where((i) => i.type == ItemType.donation).toList();
        final newRentalItems =
            newItems.where((i) => i.type == ItemType.rental).toList();
        final newThriftingItems =
            newItems.where((i) => i.type == ItemType.thrifting).toList();

        emit(currentState.copyWith(
          status: BrowseStatus.success,
          donationItems: isLoadMore
              ? (List.of(currentState.donationItems)..addAll(newDonationItems))
              : newDonationItems,
          rentalItems: isLoadMore
              ? (List.of(currentState.rentalItems)..addAll(newRentalItems))
              : newRentalItems,
          thriftingItems: isLoadMore
              ? (List.of(currentState.thriftingItems)
                ..addAll(newThriftingItems))
              : newThriftingItems,
          currentPage: pageToFetch,
          hasReachedEnd: newItems.length < 10,
          isLoadingMore: false,
        ));
      },
    );
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

  Future<void> _onLoadMoreItems(
      LoadMoreItems event, Emitter<BrowseState> emit) async {
    if (state.isLoadingMore || state.hasReachedEnd) return;
    emit(state.copyWith(isLoadingMore: true));
    await _performSearch(emit, state, isLoadMore: true);
  }

  Future<void> _onRefreshItems(
      RefreshItems event, Emitter<BrowseState> emit) async {
    emit(state.copyWith(status: BrowseStatus.loading));
    await _performSearch(emit, state);
  }
}
