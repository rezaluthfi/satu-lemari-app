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
    on<BrowseDataFetched>(_onBrowseDataFetched);
    on<TabChanged>(_onTabChanged);
    on<FilterApplied>(_onFilterApplied);
    on<ResetFilters>(_onResetFilters);
    on<SearchTermChanged>(_onSearchTermChanged,
        transformer: (events, mapper) => events
            .debounceTime(const Duration(milliseconds: 400))
            .switchMap(mapper));
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
    await _performSearch(emit, state.copyWith(activeTab: 'donation'));
    await _performSearch(emit, state.copyWith(activeTab: 'rental'));
  }

  Future<void> _onTabChanged(
      TabChanged event, Emitter<BrowseState> emit) async {
    _searchSubscription?.cancel();
    _searchSubscription = null;

    final newTab = event.index == 0 ? 'donation' : 'rental';
    if (state.activeTab == newTab) return;

    // Cek apakah ada filter harga yang aktif SEBELUM pindah tab.
    final bool hadPriceFilter = state.minPrice != null ||
        state.maxPrice != null ||
        state.sortBy == 'price';

    if (newTab == 'donation' && hadPriceFilter) {
      // Jika pindah ke Donasi DAN ada filter harga, emit state notifikasi
      // sambil mereset semua filter yang berhubungan dengan harga.
      emit(PriceFilterIgnoredNotification.from(
        state,
        activeTab: newTab,
        minPrice: const Object(), // Reset ke null
        maxPrice: const Object(), // Reset ke null
        sortBy: state.sortBy == 'price'
            ? const Object()
            : null, // Reset jika 'price'
        sortOrder: state.sortBy == 'price'
            ? const Object()
            : null, // Reset jika 'price'
      ));
    } else {
      // Jika tidak, cukup ganti tab seperti biasa.
      emit(state.copyWith(activeTab: newTab));
    }

    // Setelah mengganti tab, selalu fetch ulang data jika ada filter aktif
    // untuk memastikan data yang ditampilkan konsisten.
    final latestState = state;
    final currentItems = newTab == 'donation'
        ? latestState.donationItems
        : latestState.rentalItems;
    final hasActiveFilters = latestState.query.isNotEmpty ||
        latestState.categoryId != null ||
        latestState.size != null ||
        latestState.sortBy != null ||
        latestState.city != null ||
        (newTab == 'rental' &&
            (latestState.minPrice != null || latestState.maxPrice != null));

    if (currentItems.isEmpty || hasActiveFilters) {
      await _performSearch(emit, latestState);
    }
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

    emit(newState);
    await _performSearch(emit, newState);
  }

  Future<void> _onResetFilters(
      ResetFilters event, Emitter<BrowseState> emit) async {
    _searchSubscription?.cancel();
    final newState = BrowseState.initial().copyWith(activeTab: state.activeTab);
    emit(newState);
    await _performSearch(emit, newState);
  }

  Future<void> _onSearchTermChanged(
      SearchTermChanged event, Emitter<BrowseState> emit) async {
    emit(state.copyWith(
      query: event.query,
      suggestionStatus: SuggestionStatus.initial,
      suggestions: [],
    ));
    await _performSearch(emit, state.copyWith(query: event.query));
  }

  Future<void> _onSearchCleared(
      SearchCleared event, Emitter<BrowseState> emit) async {
    _searchSubscription?.cancel();
    final newState = state.copyWith(
        query: '', suggestionStatus: SuggestionStatus.initial, suggestions: []);
    emit(newState);
    await _performSearch(emit, newState);
  }

  Future<void> _onIntentAnalysisAndSearchRequested(
    IntentAnalysisAndSearchRequested event,
    Emitter<BrowseState> emit,
  ) async {
    // ... (kode ini tetap sama, tidak perlu diubah)
    _searchSubscription?.cancel();
    _searchSubscription = null;
    final loadingState = state.copyWith(
      query: event.query,
      suggestionStatus: SuggestionStatus.initial,
      suggestions: [],
    );
    if (state.activeTab == 'donation') {
      emit(loadingState.copyWith(donationStatus: BrowseStatus.loading));
    } else {
      emit(loadingState.copyWith(rentalStatus: BrowseStatus.loading));
    }
    final result = await analyzeIntent(event.query);
    await result.fold(
      (failure) async {
        final errorState = state.copyWith(query: event.query);
        if (state.activeTab == 'donation') {
          emit(errorState.copyWith(
              donationStatus: BrowseStatus.error,
              donationError: failure.message));
        } else {
          emit(errorState.copyWith(
              rentalStatus: BrowseStatus.error, rentalError: failure.message));
        }
      },
      (intent) async {
        final filters = intent.filters;
        final newState = state.copyWith(
          query: filters.search ?? event.query,
          categoryId: filters.categoryId,
          size: filters.size,
          minPrice: null,
          maxPrice: state.activeTab == 'rental'
              ? (filters.maxPrice?.toDouble())
              : null,
          sortBy: null,
          sortOrder: null,
          city: null,
        );
        await _performSearch(emit, newState);
      },
    );
  }

  Future<void> _onSuggestionsRequested(
      SuggestionsRequested event, Emitter<BrowseState> emit) async {
    // ... (kode ini tetap sama, tidak perlu diubah)
    if (event.query.trim().isEmpty) {
      emit(state.copyWith(
        suggestionStatus: SuggestionStatus.initial,
        suggestions: [],
      ));
      return;
    }
    emit(state.copyWith(suggestionStatus: SuggestionStatus.loading));
    final result = await getAiSuggestions(event.query);
    result.fold(
      (failure) => emit(state.copyWith(
        suggestionStatus: SuggestionStatus.error,
        suggestionError: failure.message,
      )),
      (suggestions) => emit(state.copyWith(
        suggestionStatus: SuggestionStatus.success,
        suggestions: suggestions.suggestions,
      )),
    );
  }

  Future<void> _performSearch(
      Emitter<BrowseState> emit, BrowseState currentState) async {
    // ... (kode ini tetap sama, tidak perlu diubah)
    _searchSubscription?.cancel();
    final currentTab = currentState.activeTab;
    if (currentTab == 'donation') {
      emit(currentState.copyWith(donationStatus: BrowseStatus.loading));
    } else {
      emit(currentState.copyWith(rentalStatus: BrowseStatus.loading));
    }
    final minPrice = currentTab == 'donation' ? null : currentState.minPrice;
    final maxPrice = currentTab == 'donation' ? null : currentState.maxPrice;
    final params = SearchItemsParams(
      type: currentTab,
      query: currentState.query,
      categoryId: currentState.categoryId,
      size: currentState.size,
      sortBy: currentState.sortBy,
      sortOrder: currentState.sortOrder,
      city: currentState.city,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
    final completer = Completer<void>();
    _searchSubscription = completer.future.asStream().listen(null);
    final result = await searchItems(params);
    if (completer.isCompleted) return;
    final latestState = state;
    if (latestState.activeTab != params.type) {
      if (!completer.isCompleted) completer.complete();
      return;
    }
    result.fold(
      (failure) {
        if (currentTab == 'donation') {
          emit(latestState.copyWith(
              donationStatus: BrowseStatus.error,
              donationError: failure.message,
              donationItems: []));
        } else {
          emit(latestState.copyWith(
              rentalStatus: BrowseStatus.error,
              rentalError: failure.message,
              rentalItems: []));
        }
      },
      (items) {
        if (currentTab == 'donation') {
          emit(latestState.copyWith(
              donationStatus: BrowseStatus.success, donationItems: items));
        } else {
          emit(latestState.copyWith(
              rentalStatus: BrowseStatus.success, rentalItems: items));
        }
      },
    );
    if (!completer.isCompleted) {
      completer.complete();
    }
  }
}
