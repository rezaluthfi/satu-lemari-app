import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:satulemari/features/history/domain/entities/request_item.dart';
import 'package:satulemari/features/history/domain/usecases/get_my_requests_usecase.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetMyRequestsUseCase getMyRequests;

  HistoryBloc({required this.getMyRequests}) : super(const HistoryState()) {
    on<FetchAllHistoryTypes>(_onFetchAllHistoryTypes);
    on<FetchHistory>(_onFetchHistory);
    on<HistoryReset>(_onHistoryReset);
    on<LoadMoreHistory>(_onLoadMoreHistory);
    on<RefreshHistory>(_onRefreshHistory);
  }

  Future<void> _onFetchAllHistoryTypes(
      FetchAllHistoryTypes event, Emitter<HistoryState> emit) async {
    // Set semua status ke loading secara bersamaan
    emit(state.copyWith(
      donationStatus: HistoryStatus.loading,
      rentalStatus: HistoryStatus.loading,
      thriftingStatus: HistoryStatus.loading,
    ));

    // Jalankan semua request API secara paralel
    final results = await Future.wait([
      getMyRequests(
          const GetMyRequestsParams(type: 'donation', page: 1, limit: 10)),
      getMyRequests(
          const GetMyRequestsParams(type: 'rental', page: 1, limit: 10)),
      getMyRequests(
          const GetMyRequestsParams(type: 'thrifting', page: 1, limit: 10)),
    ]);

    // Pastikan BLoC belum ditutup
    if (isClosed) return;

    final donationResult = results[0];
    final rentalResult = results[1];
    final thriftingResult = results[2];

    // Bangun state akhir dari semua hasil
    emit(state.copyWith(
      donationStatus:
          donationResult.isRight() ? HistoryStatus.loaded : HistoryStatus.error,
      donationRequests: donationResult.getOrElse(() => []),
      donationError: donationResult.isLeft()
          ? (donationResult as Left).value.message
          : null,
      donationHasReachedEnd:
          donationResult.fold((l) => true, (r) => r.length < 10),
      rentalStatus:
          rentalResult.isRight() ? HistoryStatus.loaded : HistoryStatus.error,
      rentalRequests: rentalResult.getOrElse(() => []),
      rentalError:
          rentalResult.isLeft() ? (rentalResult as Left).value.message : null,
      rentalHasReachedEnd: rentalResult.fold((l) => true, (r) => r.length < 10),
      thriftingStatus: thriftingResult.isRight()
          ? HistoryStatus.loaded
          : HistoryStatus.error,
      thriftingRequests: thriftingResult.getOrElse(() => []),
      thriftingError: thriftingResult.isLeft()
          ? (thriftingResult as Left).value.message
          : null,
      thriftingHasReachedEnd:
          thriftingResult.fold((l) => true, (r) => r.length < 10),
    ));
  }

  void _onHistoryReset(HistoryReset event, Emitter<HistoryState> emit) {
    debugPrint('HistoryBloc state has been reset.');
    emit(const HistoryState());
  }

  Future<void> _onFetchHistory(
      FetchHistory event, Emitter<HistoryState> emit) async {
    switch (event.type) {
      case 'donation':
        emit(state.copyWith(donationStatus: HistoryStatus.loading));
        break;
      case 'rental':
        emit(state.copyWith(rentalStatus: HistoryStatus.loading));
        break;
      case 'thrifting':
        emit(state.copyWith(thriftingStatus: HistoryStatus.loading));
        break;
    }

    final result = await getMyRequests(GetMyRequestsParams(
      type: event.type,
      page: 1,
      limit: 10,
    ));

    // Tambahkan delay kecil untuk memastikan UI sempat menampilkan shimmer
    await Future.delayed(const Duration(milliseconds: 300));

    result.fold(
      (failure) {
        switch (event.type) {
          case 'donation':
            emit(state.copyWith(
              donationStatus: HistoryStatus.error,
              donationError: failure.message,
            ));
            break;
          case 'rental':
            emit(state.copyWith(
              rentalStatus: HistoryStatus.error,
              rentalError: failure.message,
            ));
            break;
          case 'thrifting':
            emit(state.copyWith(
              thriftingStatus: HistoryStatus.error,
              thriftingError: failure.message,
            ));
            break;
        }
      },
      (data) {
        switch (event.type) {
          case 'donation':
            emit(state.copyWith(
              donationStatus: HistoryStatus.loaded,
              donationRequests: data,
              donationCurrentPage: 1,
              donationHasReachedEnd: data.length < 10,
            ));
            break;
          case 'rental':
            emit(state.copyWith(
              rentalStatus: HistoryStatus.loaded,
              rentalRequests: data,
              rentalCurrentPage: 1,
              rentalHasReachedEnd: data.length < 10,
            ));
            break;
          case 'thrifting':
            emit(state.copyWith(
              thriftingStatus: HistoryStatus.loaded,
              thriftingRequests: data,
              thriftingCurrentPage: 1,
              thriftingHasReachedEnd: data.length < 10,
            ));
            break;
        }
      },
    );
  }

  Future<void> _onLoadMoreHistory(
      LoadMoreHistory event, Emitter<HistoryState> emit) async {
    final type = event.type;
    int currentPage;
    bool isLoadingOrEnd;

    switch (type) {
      case 'donation':
        isLoadingOrEnd =
            state.donationIsLoadingMore || state.donationHasReachedEnd;
        currentPage = state.donationCurrentPage;
        if (!isLoadingOrEnd) emit(state.copyWith(donationIsLoadingMore: true));
        break;
      case 'rental':
        isLoadingOrEnd = state.rentalIsLoadingMore || state.rentalHasReachedEnd;
        currentPage = state.rentalCurrentPage;
        if (!isLoadingOrEnd) emit(state.copyWith(rentalIsLoadingMore: true));
        break;
      case 'thrifting':
        isLoadingOrEnd =
            state.thriftingIsLoadingMore || state.thriftingHasReachedEnd;
        currentPage = state.thriftingCurrentPage;
        if (!isLoadingOrEnd) emit(state.copyWith(thriftingIsLoadingMore: true));
        break;
      default:
        return;
    }

    if (isLoadingOrEnd) return;

    final nextPage = currentPage + 1;

    final result = await getMyRequests(GetMyRequestsParams(
      type: type,
      page: nextPage,
      limit: 10,
    ));

    result.fold(
      (failure) {
        switch (type) {
          case 'donation':
            emit(state.copyWith(donationIsLoadingMore: false));
            break;
          case 'rental':
            emit(state.copyWith(rentalIsLoadingMore: false));
            break;
          case 'thrifting':
            emit(state.copyWith(thriftingIsLoadingMore: false));
            break;
        }
        debugPrint('Load more history failed for $type: ${failure.message}');
      },
      (newItems) {
        switch (type) {
          case 'donation':
            final updatedItems = [...state.donationRequests, ...newItems];
            emit(state.copyWith(
              donationRequests: updatedItems,
              donationIsLoadingMore: false,
              donationCurrentPage: nextPage,
              donationHasReachedEnd: newItems.length < 10,
            ));
            break;
          case 'rental':
            final updatedItems = [...state.rentalRequests, ...newItems];
            emit(state.copyWith(
              rentalRequests: updatedItems,
              rentalIsLoadingMore: false,
              rentalCurrentPage: nextPage,
              rentalHasReachedEnd: newItems.length < 10,
            ));
            break;
          case 'thrifting':
            final updatedItems = [...state.thriftingRequests, ...newItems];
            emit(state.copyWith(
              thriftingRequests: updatedItems,
              thriftingIsLoadingMore: false,
              thriftingCurrentPage: nextPage,
              thriftingHasReachedEnd: newItems.length < 10,
            ));
            break;
        }
      },
    );
  }

  Future<void> _onRefreshHistory(
      RefreshHistory event, Emitter<HistoryState> emit) async {
    final type = event.type;

    // Kosongkan list dan set status ke loading
    switch (type) {
      case 'donation':
        emit(state.copyWith(
            donationStatus: HistoryStatus.loading, donationRequests: []));
        break;
      case 'rental':
        emit(state
            .copyWith(rentalStatus: HistoryStatus.loading, rentalRequests: []));
        break;
      case 'thrifting':
        emit(state.copyWith(
            thriftingStatus: HistoryStatus.loading, thriftingRequests: []));
        break;
    }

    add(FetchHistory(type: type));
  }
}
