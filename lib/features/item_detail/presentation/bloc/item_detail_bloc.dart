import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/browse/domain/usecases/get_similar_items_usecase.dart';
import 'package:satulemari/features/category_items/domain/entities/item_entity.dart';
import 'package:satulemari/features/history/domain/entities/request_item.dart';
import 'package:satulemari/features/history/domain/usecases/get_my_requests_usecase.dart';
import 'package:satulemari/features/item_detail/domain/entities/item_detail.dart';
import 'package:satulemari/features/item_detail/domain/usecases/get_item_by_id_usecase.dart';
import 'package:satulemari/features/profile/domain/entities/dashboard_stats.dart';
import 'package:satulemari/features/profile/domain/usecases/get_dashboard_stats_usecase.dart';

part 'item_detail_event.dart';
part 'item_detail_state.dart';

class ItemDetailBloc extends Bloc<ItemDetailEvent, ItemDetailState> {
  final GetItemByIdUseCase getItemById;
  final GetMyRequestsUseCase getMyRequests;
  final GetDashboardStatsUseCase getDashboardStats;
  final GetSimilarItemsUseCase getSimilarItems;

  ItemDetailBloc({
    required this.getItemById,
    required this.getMyRequests,
    required this.getDashboardStats,
    required this.getSimilarItems,
  }) : super(ItemDetailInitial()) {
    on<FetchItemDetail>(_onFetchItemDetail);
    on<FetchSimilarItems>(_onFetchSimilarItems);
  }

  Future<void> _onFetchItemDetail(
    FetchItemDetail event,
    Emitter<ItemDetailState> emit,
  ) async {
    emit(ItemDetailLoading());
    try {
      debugPrint("[ItemDetailBloc] 1. Fetching item detail...");
      final itemResult = await getItemById(GetItemByIdParams(id: event.id));

      await itemResult.fold(
        (failure) async {
          debugPrint(
              "[ItemDetailBloc] X. FAILED to fetch item detail: ${failure.message}");
          emit(ItemDetailError(
              'Gagal memuat detail barang: ${failure.message}'));
        },
        (item) async {
          debugPrint(
              "[ItemDetailBloc] 2. SUCCESS fetching item detail. Name: ${item.name}");

          // LANGSUNG EMIT STATE LOADED DENGAN DATA UTAMA
          // Gunakan state tombol default/aman untuk sementara.
          // Ini akan menghilangkan shimmer SEGERA.
          emit(ItemDetailLoaded(item,
              buttonState: ItemDetailButtonState.active));

          // Panggil similar items segera.
          add(FetchSimilarItems(item.id));

          // Sekarang, jalankan pemrosesan data sekunder di latar belakang.
          // Kita tidak akan 'await' di sini agar UI tidak terblokir.
          _processSecondaryData(item);
        },
      );
    } catch (e, stacktrace) {
      debugPrint("[ItemDetailBloc] FATAL ERROR in _onFetchItemDetail: $e");
      debugPrint(stacktrace.toString());
      emit(ItemDetailError('Terjadi kesalahan tidak terduga: $e'));
    }
  }

  // Method baru untuk memproses data sekunder secara terpisah
  void _processSecondaryData(ItemDetail item) async {
    try {
      debugPrint(
          "[ItemDetailBloc] 3. Processing secondary data in background...");
      final results = await Future.wait([
        getMyRequests(const GetMyRequestsParams(type: 'donation')),
        getMyRequests(const GetMyRequestsParams(type: 'rental')),
        getDashboardStats(NoParams()),
      ]);

      debugPrint("[ItemDetailBloc] 4. All secondary data fetched.");
      // Pastikan state saat ini masih Loaded sebelum melanjutkan
      if (state is! ItemDetailLoaded) return;

      final currentState = state as ItemDetailLoaded;

      // Pastikan item ID masih sama, untuk menghindari update halaman yang salah
      if (currentState.item.id != item.id) return;

      final donationRequestsResult =
          results[0] as Either<Failure, List<RequestItem>>;
      final rentalRequestsResult =
          results[1] as Either<Failure, List<RequestItem>>;
      final statsResult = results[2] as Either<Failure, DashboardStats>;

      final List<RequestItem> allRequests = [];
      donationRequestsResult.fold((_) {}, (list) => allRequests.addAll(list));
      rentalRequestsResult.fold((_) {}, (list) => allRequests.addAll(list));

      DashboardStats? stats;
      statsResult.fold((_) => stats = null, (s) => stats = s);

      debugPrint("[ItemDetailBloc] 5. Determining final button state...");
      ItemDetailButtonState buttonState;

      if (item.availableQuantity <= 0) {
        buttonState = ItemDetailButtonState.outOfStock;
      } else if (allRequests.any((req) =>
          req.itemName == item.name && req.status.toLowerCase() == 'pending')) {
        buttonState = ItemDetailButtonState.pendingRequest;
      } else if (item.type.toLowerCase() == 'donation' &&
          (stats?.weeklyQuotaRemaining ?? 0) <= 0) {
        buttonState = ItemDetailButtonState.quotaExceeded;
      } else {
        buttonState = ItemDetailButtonState.active;
      }

      debugPrint(
          "[ItemDetailBloc] 6. Emitting updated ItemDetailLoaded with final button state: $buttonState");
      // Emit state baru dengan buttonState yang sudah diperbarui
      emit(currentState.copyWith(buttonState: buttonState));
    } catch (e, stacktrace) {
      debugPrint("[ItemDetailBloc] FATAL ERROR in _processSecondaryData: $e");
      debugPrint(stacktrace.toString());
      // Di sini kita tidak emit error, karena halaman utama sudah tampil.
      // Cukup log errornya saja.
    }
  }

  Future<void> _onFetchSimilarItems(
    FetchSimilarItems event,
    Emitter<ItemDetailState> emit,
  ) async {
    if (state is! ItemDetailLoaded) return;

    final currentState = state as ItemDetailLoaded;
    emit(currentState.copyWith(similarItemsStatus: SimilarItemsStatus.loading));

    final result =
        await getSimilarItems(GetSimilarItemsParams(itemId: event.itemId));

    if (state is ItemDetailLoaded) {
      final latestState = state as ItemDetailLoaded;
      result.fold(
        (failure) {
          emit(latestState.copyWith(
            similarItemsStatus: SimilarItemsStatus.error,
            similarItemsError: failure.message,
          ));
        },
        (items) {
          emit(latestState.copyWith(
            similarItemsStatus: SimilarItemsStatus.loaded,
            similarItems: items,
          ));
        },
      );
    }
  }
}
