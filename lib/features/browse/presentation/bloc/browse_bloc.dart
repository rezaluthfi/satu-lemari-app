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
    await _performSearch(emit, state);
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

    final singleWordQuery = stateWithMemory.query.split(' ').first;

    final params = SearchItemsParams(
      type: currentTab,
      query: singleWordQuery,
      categoryId: stateWithMemory.categoryId,
      size: stateWithMemory.size,
      color: stateWithMemory.color,
      condition: stateWithMemory.condition,
      sortBy: stateWithMemory.sortBy,
      sortOrder: stateWithMemory.sortOrder,
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
          ));
        } else {
          emit(latestState.copyWith(
            rentalStatus: BrowseStatus.error,
            rentalError: failure.message,
            rentalItems: [],
            lastPerformedQuery: stateWithMemory.lastPerformedQuery,
          ));
        }
      },
      (items) {
        if (currentTab == 'donation') {
          emit(latestState.copyWith(
            donationStatus: BrowseStatus.success,
            donationItems: items,
            lastPerformedQuery: stateWithMemory.lastPerformedQuery,
          ));
        } else {
          emit(latestState.copyWith(
            rentalStatus: BrowseStatus.success,
            rentalItems: items,
            lastPerformedQuery: stateWithMemory.lastPerformedQuery,
          ));
        }
      },
    );
    if (!completer.isCompleted) {
      completer.complete();
    }
  }
}
