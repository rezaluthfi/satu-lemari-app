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

  // Cache untuk data original (tanpa filter)
  List<Item> _originalDonationItems = [];
  List<Item> _originalRentalItems = [];

  // StreamController untuk membatalkan pencarian yang sedang berlangsung
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

    add(BrowseDataFetched());
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
    // Batalkan pencarian yang sedang berlangsung
    _searchSubscription?.cancel();

    final newTab = event.index == 0 ? 'donation' : 'rental';
    if (state.activeTab == newTab) return;

    final newState = state.copyWith(
        activeTab: newTab, query: '', categoryId: null, size: null);
    emit(newState);

    // Periksa apakah sudah ada data original untuk tab ini
    final hasOriginalData =
        (newTab == 'donation' && _originalDonationItems.isNotEmpty) ||
            (newTab == 'rental' && _originalRentalItems.isNotEmpty);

    if (hasOriginalData) {
      // Tampilkan data original yang sudah ada
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
    print(
        'FilterApplied event: categoryId=${event.categoryId}, size=${event.size}');

    // Batalkan pencarian yang sedang berlangsung
    _searchSubscription?.cancel();

    // FIXED: Use proper copyWith with explicit null handling
    final newState =
        state.copyWith(categoryId: event.categoryId, size: event.size);

    print(
        'New state after filter applied: categoryId=${newState.categoryId}, size=${newState.size}');

    emit(newState);
    await _performSearch(emit, newState);
  }

  Future<void> _onResetFilters(
      ResetFilters event, Emitter<BrowseState> emit) async {
    print('ResetFilters event triggered');

    // Batalkan pencarian yang sedang berlangsung
    _searchSubscription?.cancel();

    // FIXED: Explicitly pass null values to reset filters
    final newState = state.copyWith(
      categoryId: null,
      size: null,
      query: '', // Also clear search query when resetting
    );

    print(
        'New state after reset: categoryId=${newState.categoryId}, size=${newState.size}, query="${newState.query}"');

    emit(newState);

    // Show original data if available, otherwise perform search
    final currentTab = newState.activeTab;
    final hasOriginalData =
        (currentTab == 'donation' && _originalDonationItems.isNotEmpty) ||
            (currentTab == 'rental' && _originalRentalItems.isNotEmpty);

    if (hasOriginalData) {
      print('Restoring original data for tab: $currentTab');
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
      print('No original data found, performing new search');
      await _performSearch(emit, newState);
    }
  }

  Future<void> _onSearchTermChanged(
      SearchTermChanged event, Emitter<BrowseState> emit) async {
    // Jika query kosong setelah debounce, gunakan SearchCleared logic
    if (event.query.trim().isEmpty) {
      await _onSearchCleared(SearchCleared(), emit);
    } else {
      await _performSearch(emit, state.copyWith(query: event.query));
    }
  }

  Future<void> _onSearchCleared(
      SearchCleared event, Emitter<BrowseState> emit) async {
    // Batalkan semua pencarian yang sedang berlangsung
    _searchSubscription?.cancel();

    print('SearchCleared called - cancelling active searches');

    // FIXED: Don't reset filters when clearing search, only clear query
    final newState = state.copyWith(query: '');

    // Langsung tampilkan data original jika tersedia dan tidak ada filter aktif
    final currentTab = newState.activeTab;
    final hasFilters = newState.categoryId != null || newState.size != null;
    final hasOriginalData =
        (currentTab == 'donation' && _originalDonationItems.isNotEmpty) ||
            (currentTab == 'rental' && _originalRentalItems.isNotEmpty);

    print(
        'SearchCleared - Tab: $currentTab, HasOriginalData: $hasOriginalData, HasFilters: $hasFilters');

    if (hasOriginalData && !hasFilters) {
      if (currentTab == 'donation') {
        print('Restoring ${_originalDonationItems.length} donation items');
        emit(newState.copyWith(
          donationStatus: BrowseStatus.success,
          donationItems: List.from(_originalDonationItems),
        ));
      } else {
        print('Restoring ${_originalRentalItems.length} rental items');
        emit(newState.copyWith(
          rentalStatus: BrowseStatus.success,
          rentalItems: List.from(_originalRentalItems),
        ));
      }
    } else {
      // Jika ada filter atau tidak ada data original, lakukan pencarian baru
      print('Performing search with filters or no original data');
      emit(newState);
      await _performSearch(emit, newState);
    }
  }

  Future<void> _performSearch(
      Emitter<BrowseState> emit, BrowseState currentState,
      {bool forceRefresh = false}) async {
    // Batalkan pencarian sebelumnya
    _searchSubscription?.cancel();

    final currentTab = currentState.activeTab;
    final searchId = DateTime.now().millisecondsSinceEpoch.toString();

    print(
        'Starting search - ID: $searchId, Tab: $currentTab, Query: "${currentState.query}", '
        'CategoryId: ${currentState.categoryId}, Size: ${currentState.size}');

    // Set status loading untuk tab yang relevan
    if (currentTab == 'donation') {
      emit(currentState.copyWith(donationStatus: BrowseStatus.loading));
    } else {
      emit(currentState.copyWith(rentalStatus: BrowseStatus.loading));
    }

    final params = SearchItemsParams(
      type: currentTab,
      query: currentState.query,
      categoryId: currentState.categoryId,
      size: currentState.size,
    );

    // Buat Completer untuk tracking search ini
    final completer = Completer<void>();
    _searchSubscription = completer.future.asStream().listen(null);

    try {
      final result = await searchItems(params);

      // Check apakah search ini sudah dibatalkan
      if (_searchSubscription?.isPaused == true || completer.isCompleted) {
        print('Search cancelled - ID: $searchId');
        return;
      }

      // Ambil state terbaru setelah await
      final latestState = state;

      // Pastikan kita masih di tab dan dengan parameter yang sama
      if (latestState.activeTab == currentTab &&
          latestState.query == currentState.query &&
          latestState.categoryId == currentState.categoryId &&
          latestState.size == currentState.size) {
        print('Search completed - ID: $searchId, Tab: $currentTab');

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
            // Simpan data original hanya jika query kosong dan tidak ada filter
            final isOriginalData = currentState.query.isEmpty &&
                currentState.categoryId == null &&
                currentState.size == null;

            if (isOriginalData) {
              print(
                  'Saving original data - ${items.length} items for $currentTab');
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
      } else {
        print('Search outdated - ID: $searchId, ignoring results');
      }
    } catch (e) {
      print('Search error - ID: $searchId, Error: $e');
    } finally {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
  }
}
