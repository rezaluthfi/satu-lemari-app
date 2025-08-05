// lib/features/history/presentation/bloc/history_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:satulemari/features/history/domain/entities/request_item.dart';
import 'package:satulemari/features/history/domain/usecases/get_my_requests_usecase.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetMyRequestsUseCase getMyRequests;

  HistoryBloc({required this.getMyRequests}) : super(const HistoryState()) {
    on<FetchHistory>(_onFetchHistory);
    // --- TAMBAHKAN HANDLER INI ---
    on<HistoryReset>(_onHistoryReset);
    on<LoadMoreHistory>(_onLoadMoreHistory);
    on<RefreshHistory>(_onRefreshHistory);
  }

  // --- TAMBAHKAN METHOD INI ---
  void _onHistoryReset(HistoryReset event, Emitter<HistoryState> emit) {
    debugPrint('HistoryBloc state has been reset.');
    emit(const HistoryState()); // Kembali ke state awal yang kosong
  }

  Future<void> _onFetchHistory(
      FetchHistory event, Emitter<HistoryState> emit) async {
    if (event.type == 'donation') {
      emit(state.copyWith(donationStatus: HistoryStatus.loading));
    } else {
      emit(state.copyWith(rentalStatus: HistoryStatus.loading));
    }

    final result = await getMyRequests(GetMyRequestsParams(
      type: event.type,
      page: 1,
      limit: 10,
    ));

    result.fold(
      (failure) {
        if (event.type == 'donation') {
          emit(state.copyWith(
            donationStatus: HistoryStatus.error,
            donationError: failure.message,
            donationCurrentPage: 1,
            donationHasReachedEnd: false,
            donationIsLoadingMore: false,
          ));
        } else {
          emit(state.copyWith(
            rentalStatus: HistoryStatus.error,
            rentalError: failure.message,
            rentalCurrentPage: 1,
            rentalHasReachedEnd: false,
            rentalIsLoadingMore: false,
          ));
        }
      },
      (data) {
        if (event.type == 'donation') {
          emit(state.copyWith(
            donationStatus: HistoryStatus.loaded,
            donationRequests: data,
            donationCurrentPage: 1,
            donationHasReachedEnd: data.length < 10,
            donationIsLoadingMore: false,
          ));
        } else {
          emit(state.copyWith(
            rentalStatus: HistoryStatus.loaded,
            rentalRequests: data,
            rentalCurrentPage: 1,
            rentalHasReachedEnd: data.length < 10,
            rentalIsLoadingMore: false,
          ));
        }
      },
    );
  }

  Future<void> _onLoadMoreHistory(
      LoadMoreHistory event, Emitter<HistoryState> emit) async {
    final type = event.type;

    // Check if already loading more or reached end
    if (type == 'donation') {
      if (state.donationIsLoadingMore || state.donationHasReachedEnd) return;
    } else {
      if (state.rentalIsLoadingMore || state.rentalHasReachedEnd) return;
    }

    // Set loading more state
    if (type == 'donation') {
      emit(state.copyWith(donationIsLoadingMore: true));
    } else {
      emit(state.copyWith(rentalIsLoadingMore: true));
    }

    // Get current page and increment it
    final currentPage = type == 'donation'
        ? state.donationCurrentPage
        : state.rentalCurrentPage;
    final nextPage = currentPage + 1;

    final result = await getMyRequests(GetMyRequestsParams(
      type: type,
      page: nextPage,
      limit: 10,
    ));

    result.fold(
      (failure) {
        // Handle error - don't update main error state for load more failures
        if (type == 'donation') {
          emit(state.copyWith(donationIsLoadingMore: false));
        } else {
          emit(state.copyWith(rentalIsLoadingMore: false));
        }
        // TODO: Consider showing a snackbar for load more errors
        debugPrint('Load more history failed for $type: ${failure.message}');
      },
      (newItems) {
        // Append new items to existing list
        if (type == 'donation') {
          final updatedItems = [...state.donationRequests, ...newItems];
          emit(state.copyWith(
            donationRequests: updatedItems,
            donationIsLoadingMore: false,
            donationCurrentPage: nextPage,
            donationHasReachedEnd: newItems.length < 10,
          ));
        } else {
          final updatedItems = [...state.rentalRequests, ...newItems];
          emit(state.copyWith(
            rentalRequests: updatedItems,
            rentalIsLoadingMore: false,
            rentalCurrentPage: nextPage,
            rentalHasReachedEnd: newItems.length < 10,
          ));
        }
      },
    );
  }

  Future<void> _onRefreshHistory(
      RefreshHistory event, Emitter<HistoryState> emit) async {
    final type = event.type;

    // Reset pagination state and reload first page
    if (type == 'donation') {
      emit(state.copyWith(
        donationStatus: HistoryStatus.loading,
        donationCurrentPage: 1,
        donationHasReachedEnd: false,
        donationIsLoadingMore: false,
      ));
    } else {
      emit(state.copyWith(
        rentalStatus: HistoryStatus.loading,
        rentalCurrentPage: 1,
        rentalHasReachedEnd: false,
        rentalIsLoadingMore: false,
      ));
    }

    // Fetch first page
    await _onFetchHistory(FetchHistory(type: type), emit);
  }
}
