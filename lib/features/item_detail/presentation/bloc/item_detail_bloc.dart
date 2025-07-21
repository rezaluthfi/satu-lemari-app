import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart'; // --- PERBAIKAN: Pastikan dartz diimpor
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/errors/failures.dart'; // --- PERBAIKAN: Pastikan Failure diimpor
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/history/domain/entities/request_item.dart'; // --- PERBAIKAN: Pastikan RequestItem diimpor
import 'package:satulemari/features/history/domain/usecases/get_my_requests_usecase.dart';
import 'package:satulemari/features/item_detail/domain/entities/item_detail.dart';
import 'package:satulemari/features/item_detail/domain/usecases/get_item_by_id_usecase.dart';
import 'package:satulemari/features/profile/domain/entities/dashboard_stats.dart'; // --- PERBAIKAN: Pastikan DashboardStats diimpor
import 'package:satulemari/features/profile/domain/usecases/get_dashboard_stats_usecase.dart';

part 'item_detail_event.dart';
part 'item_detail_state.dart';

class ItemDetailBloc extends Bloc<ItemDetailEvent, ItemDetailState> {
  final GetItemByIdUseCase getItemById;
  final GetMyRequestsUseCase getMyRequests;
  final GetDashboardStatsUseCase getDashboardStats;

  ItemDetailBloc({
    required this.getItemById,
    required this.getMyRequests,
    required this.getDashboardStats,
  }) : super(ItemDetailInitial()) {
    on<FetchItemDetail>(_onFetchItemDetail);
  }

  Future<void> _onFetchItemDetail(
    FetchItemDetail event,
    Emitter<ItemDetailState> emit,
  ) async {
    emit(ItemDetailLoading());

    // Panggil semua data yang dibutuhkan secara paralel.
    // getMyRequests dipanggil dua kali untuk 'donation' dan 'rental'.
    final results = await Future.wait([
      getItemById(GetItemByIdParams(id: event.id)),
      getMyRequests(const GetMyRequestsParams(type: 'donation')),
      getMyRequests(const GetMyRequestsParams(type: 'rental')),
      getDashboardStats(NoParams()),
    ]);

    // Ambil hasil utama (detail item). Jika ini gagal, seluruh halaman gagal.
    final itemResult = results[0] as Either<Failure, ItemDetail>;

    itemResult.fold(
      (failure) {
        // Jika gagal mendapatkan item, tampilkan error dan hentikan proses.
        emit(ItemDetailError('Gagal memuat detail barang: ${failure.message}'));
      },
      (item) {
        // Jika item berhasil didapat, proses data sekunder.
        final donationRequestsResult =
            results[1] as Either<Failure, List<RequestItem>>;
        final rentalRequestsResult =
            results[2] as Either<Failure, List<RequestItem>>;
        final statsResult = results[3] as Either<Failure, DashboardStats>;

        // Gabungkan semua request menjadi satu list.
        // `fold` digunakan agar jika salah satu gagal, list tetap bisa diproses.
        final List<RequestItem> allRequests = [];
        donationRequestsResult.fold(
            (_) => null, (list) => allRequests.addAll(list));
        rentalRequestsResult.fold(
            (_) => null, (list) => allRequests.addAll(list));

        // Ambil data statistik. Jika gagal, `stats` akan null.
        DashboardStats? stats;
        statsResult.fold((_) => stats = null, (s) => stats = s);

        // Tentukan state tombol berdasarkan kondisi item.
        ItemDetailButtonState buttonState;

        // Prioritas 1: Stok habis (paling penting)
        if (item.availableQuantity <= 0) {
          buttonState = ItemDetailButtonState.outOfStock;
        }
        // Prioritas 2: Ada request pending untuk item ini
        // Mencocokkan berdasarkan `itemName` karena `RequestItem` tidak punya `itemId`.
        // Ini asumsi yang paling aman berdasarkan struktur entitas yang diberikan.
        else if (allRequests.any((req) =>
            req.itemName == item.name &&
            req.status.toLowerCase() == 'pending')) {
          buttonState = ItemDetailButtonState.pendingRequest;
        }
        // Prioritas 3: Kuota donasi habis (hanya berlaku untuk item donasi)
        // Cek juga apakah `stats` tidak null untuk menghindari error.
        else if (item.type.toLowerCase() == 'donation' &&
            stats != null &&
            (stats?.weeklyQuotaRemaining ?? 0) <= 0) {
          buttonState = ItemDetailButtonState.quotaExceeded;
        }
        // Kondisi default: Tombol aktif
        else {
          buttonState = ItemDetailButtonState.active;
        }

        emit(ItemDetailLoaded(item, buttonState: buttonState));
      },
    );
  }
}
