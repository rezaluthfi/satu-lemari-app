import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/features/browse/domain/usecases/search_items_usecase.dart';
import 'package:satulemari/features/category_items/domain/entities/item_entity.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

part 'browse_event.dart';
part 'browse_state.dart';

class BrowseBloc extends Bloc<BrowseEvent, BrowseState> {
  final SearchItemsUseCase searchItems;

  List<Item> _originalDonationItems = [];
  List<Item> _originalRentalItems = [];
  StreamSubscription<void>? _searchSubscription;

  BrowseBloc({required this.searchItems}) : super(BrowseState.initial()) {
    on<BrowseDataFetched>(_onBrowseDataFetched);
    on<TabChanged>(_onTabChanged);
    on<FilterApplied>(_onFilterApplied);
    on<ResetFilters>(_onResetFilters);
    on<SearchTermChanged>(
      _onSearchTermChanged,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 300))
          .distinct()
          .switchMap(mapper),
    );
    on<SearchCleared>(_onSearchCleared);
  }

  @override
  Future<void> close() {
    _searchSubscription?.cancel();
    return super.close();
  }

  Future<void> _onBrowseDataFetched(
      BrowseDataFetched event, Emitter<BrowseState> emit) async {
    await _performSearch(emit, state, forceRefresh: true);
  }

  Future<void> _onTabChanged(
      TabChanged event, Emitter<BrowseState> emit) async {
    _searchSubscription?.cancel();
    final newTab = event.index == 0 ? 'donation' : 'rental';
    if (state.activeTab == newTab) return;

    // Saat ganti tab, reset semua filter
    final newState = state.copyWith(
      activeTab: newTab,
      query: '',
      categoryId: null,
      size: null,
      sortBy: null,
      sortOrder: null,
      city: null,
      minPrice: null,
      maxPrice: null,
    );
    emit(newState);

    final hasOriginalData =
        (newTab == 'donation' && _originalDonationItems.isNotEmpty) ||
            (newTab == 'rental' && _originalRentalItems.isNotEmpty);

    if (hasOriginalData) {
      if (newTab == 'donation') {
        emit(newState.copyWith(
          donationStatus: BrowseStatus.success,
          donationItems: _originalDonationItems,
        ));
      } else {
        emit(newState.copyWith(
          rentalStatus: BrowseStatus.success,
          rentalItems: _originalRentalItems,
        ));
      }
    } else {
      await _performSearch(emit, newState);
    }
  }

  Future<void> _onFilterApplied(
      FilterApplied event, Emitter<BrowseState> emit) async {
    _searchSubscription?.cancel();

    // Perbarui state dengan semua filter yang diterapkan
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

    // Reset semua parameter filter ke null
    final newState = state.copyWith(
      categoryId: null,
      size: null,
      sortBy: null,
      sortOrder: null,
      city: null,
      minPrice: null,
      maxPrice: null,
      query: '',
    );

    emit(newState);

    final currentTab = newState.activeTab;
    final hasOriginalData =
        (currentTab == 'donation' && _originalDonationItems.isNotEmpty) ||
            (currentTab == 'rental' && _originalRentalItems.isNotEmpty);

    if (hasOriginalData) {
      if (currentTab == 'donation') {
        emit(newState.copyWith(
          donationStatus: BrowseStatus.success,
          donationItems: List.from(_originalDonationItems),
        ));
      } else {
        emit(newState.copyWith(
          rentalStatus: BrowseStatus.success,
          rentalItems: List.from(_originalRentalItems),
        ));
      }
    } else {
      await _performSearch(emit, newState);
    }
  }

  Future<void> _onSearchTermChanged(
      SearchTermChanged event, Emitter<BrowseState> emit) async {
    if (event.query.trim().isEmpty) {
      await _onSearchCleared(SearchCleared(), emit);
    } else {
      await _performSearch(emit, state.copyWith(query: event.query));
    }
  }

  Future<void> _onSearchCleared(
      SearchCleared event, Emitter<BrowseState> emit) async {
    _searchSubscription?.cancel();
    final newState = state.copyWith(query: '');
    final currentTab = newState.activeTab;
    final hasFilters = newState.categoryId != null ||
        newState.size != null ||
        newState.sortBy != null ||
        newState.city != null ||
        newState.minPrice != null ||
        newState.maxPrice != null;

    final hasOriginalData =
        (currentTab == 'donation' && _originalDonationItems.isNotEmpty) ||
            (currentTab == 'rental' && _originalRentalItems.isNotEmpty);

    if (hasOriginalData && !hasFilters) {
      if (currentTab == 'donation') {
        emit(newState.copyWith(
          donationStatus: BrowseStatus.success,
          donationItems: List.from(_originalDonationItems),
        ));
      } else {
        emit(newState.copyWith(
          rentalStatus: BrowseStatus.success,
          rentalItems: List.from(_originalRentalItems),
        ));
      }
    } else {
      emit(newState);
      await _performSearch(emit, newState);
    }
  }

  Future<void> _performSearch(
      Emitter<BrowseState> emit, BrowseState currentState,
      {bool forceRefresh = false}) async {
    _searchSubscription?.cancel();
    final currentTab = currentState.activeTab;

    if (currentTab == 'donation') {
      emit(currentState.copyWith(donationStatus: BrowseStatus.loading));
    } else {
      emit(currentState.copyWith(rentalStatus: BrowseStatus.loading));
    }

    // Buat parameter pencarian dari state saat ini
    final params = SearchItemsParams(
      type: currentTab,
      query: currentState.query,
      categoryId: currentState.categoryId,
      size: currentState.size,
      sortBy: currentState.sortBy,
      sortOrder: currentState.sortOrder,
      city: currentState.city,
      minPrice: currentState.minPrice,
      maxPrice: currentState.maxPrice,
    );

    final completer = Completer<void>();
    _searchSubscription = completer.future.asStream().listen(null);

    final result = await searchItems(params);

    if (completer.isCompleted) return;

    final latestState = state;

    // Cek apakah state masih relevan
    final bool isStateRelevant = latestState.activeTab == params.type &&
        latestState.query == params.query &&
        latestState.categoryId == params.categoryId &&
        latestState.size == params.size &&
        latestState.sortBy == params.sortBy &&
        latestState.sortOrder == params.sortOrder &&
        latestState.city == params.city &&
        latestState.minPrice == params.minPrice &&
        latestState.maxPrice == params.maxPrice;

    if (isStateRelevant) {
      result.fold(
        (failure) {
          if (currentTab == 'donation') {
            emit(latestState.copyWith(
                donationStatus: BrowseStatus.error,
                donationError: failure.message));
          } else {
            emit(latestState.copyWith(
                rentalStatus: BrowseStatus.error,
                rentalError: failure.message));
          }
        },
        (items) {
          final isOriginalData = params.query == null ||
              params.query!.isEmpty &&
                  params.categoryId == null &&
                  params.size == null &&
                  params.sortBy == null &&
                  params.city == null &&
                  params.minPrice == null &&
                  params.maxPrice == null;

          if (isOriginalData || forceRefresh) {
            if (currentTab == 'donation') {
              _originalDonationItems = List.from(items);
            } else {
              _originalRentalItems = List.from(items);
            }
          }

          if (currentTab == 'donation') {
            emit(latestState.copyWith(
                donationStatus: BrowseStatus.success, donationItems: items));
          } else {
            emit(latestState.copyWith(
                rentalStatus: BrowseStatus.success, rentalItems: items));
          }
        },
      );
    }

    if (!completer.isCompleted) {
      completer.complete();
    }
  }
}
