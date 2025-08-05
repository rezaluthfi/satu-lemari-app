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
    final bool isQueryDifferent = state.query != state.lastPerformedQuery;

    if (isQueryDifferent && state.query.isNotEmpty) {
      emit(state.copyWith(query: state.lastPerformedQuery));
      return;
    }

    add(ResetFilters());
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
        lastPerformedQuery: event.query);
    // Tidak perlu emit di sini karena _performSearchForAllTabs akan melakukannya.
    await _performSearchForAllTabs(emit, newState);
  }

  Future<void> _onIntentAnalysisAndSearchRequested(
    IntentAnalysisAndSearchRequested event,
    Emitter<BrowseState> emit,
  ) async {
    emit(state.copyWith(
      query: event.query,
      suggestionStatus: SuggestionStatus.loading,
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
          categoryId: filters.categoryId ?? state.categoryId,
          size: filters.size ?? state.size,
          color: filters.color ?? state.color,
          condition: filters.condition ?? state.condition,
          maxPrice: filters.maxPrice?.toDouble() ?? state.maxPrice,
        );
        await _performSearchForAllTabs(emit, stateWithAiFilters);
      },
    );
  }

  Future<void> _onResetFilters(
      ResetFilters event, Emitter<BrowseState> emit) async {
    final cleanState =
        BrowseState.initial().copyWith(activeTab: state.activeTab);
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

    // PERBAIKAN: Gunakan state BLoC terbaru sebagai base, lalu update dengan loading status
    final latestBlocState = state;
    emit(targetTab == 'donation'
        ? latestBlocState.copyWith(donationStatus: BrowseStatus.loading)
        : latestBlocState.copyWith(rentalStatus: BrowseStatus.loading));

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
        // PERBAIKAN: Gunakan state BLoC terbaru sebagai base untuk emit error
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
        // PERBAIKAN: Gunakan state BLoC terbaru sebagai base untuk emit success
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
    await _performSearchForAllTabs(emit, state);
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
