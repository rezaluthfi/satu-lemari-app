import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/features/history/presentation/bloc/history_bloc.dart';
import 'package:satulemari/features/history/presentation/widgets/history_shimmer.dart';
import 'package:satulemari/features/history/presentation/widgets/request_list_view.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    context.read<HistoryBloc>().add(const FetchHistory(type: 'donation'));

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final type = _tabController.index == 0 ? 'donation' : 'rental';
      final state = context.read<HistoryBloc>().state;

      if (type == 'donation' && state.donationStatus == HistoryStatus.initial) {
        context.read<HistoryBloc>().add(const FetchHistory(type: 'donation'));
      } else if (type == 'rental' &&
          state.rentalStatus == HistoryStatus.initial) {
        context.read<HistoryBloc>().add(const FetchHistory(type: 'rental'));
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Riwayat Permintaan',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 28,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            child: Column(
              children: [
                _buildTabSection(),
              ],
            ),
          ),
          Container(
            height: 1,
            color: AppColors.divider.withOpacity(0.3),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // --- MODIFIKASI: Gunakan _buildHistoryView untuk setiap tab ---
                _buildHistoryView(type: 'donation'),
                _buildHistoryView(type: 'rental'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryView({required String type}) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      // buildWhen untuk optimisasi, hanya rebuild jika state yang relevan berubah
      buildWhen: (previous, current) {
        if (type == 'donation') {
          return previous.donationStatus != current.donationStatus ||
              previous.donationRequests != current.donationRequests;
        } else {
          return previous.rentalStatus != current.rentalStatus ||
              previous.rentalRequests != current.rentalRequests;
        }
      },
      builder: (context, state) {
        final status =
            type == 'donation' ? state.donationStatus : state.rentalStatus;
        final requests =
            type == 'donation' ? state.donationRequests : state.rentalRequests;
        final error =
            type == 'donation' ? state.donationError : state.rentalError;

        // --- SOLUSI INTI ADA DI SINI ---
        return RefreshIndicator(
          onRefresh: () async {
            context.read<HistoryBloc>().add(RefreshHistory(type: type));
          },
          color: AppColors.primary,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Jika sedang loading DAN belum ada data sama sekali, tampilkan shimmer
              if (status == HistoryStatus.loading && requests.isEmpty) {
                return const HistoryListShimmer();
              }

              // Jika data kosong, tampilkan pesan kosong
              if (requests.isEmpty &&
                  (status == HistoryStatus.loaded ||
                      status == HistoryStatus.error)) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: status == HistoryStatus.error
                        ? _buildErrorState(error ?? 'Terjadi kesalahan')
                        : _buildEmptyState(type),
                  ),
                );
              }

              // Jika ada data, tampilkan ListView
              return RequestListView(
                type: type, // Kirim tipe untuk logika internal
                requests: requests, // Kirim daftar request
              );
            },
          ),
        );
      },
    );
  }

  // --- BARU: Pindahkan widget _buildEmptyState dan _buildErrorState ke sini ---
  Widget _buildEmptyState(String type) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                type == 'donation'
                    ? Icons.favorite_outline_rounded
                    : Icons.shopping_bag_outlined,
                size: 40,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              type == 'donation'
                  ? 'Belum Ada Riwayat Donasi'
                  : 'Belum Ada Riwayat Sewa',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              type == 'donation'
                  ? 'Permintaan donasi Anda akan muncul di sini.'
                  : 'Permintaan sewa Anda akan muncul di sini.',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Oops, Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(24),
      ),
      child: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          return TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: AppColors.primary,
            ),
            labelColor: AppColors.textLight,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.all(2),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      size: 18,
                      color: _tabController.index == 0
                          ? AppColors.textLight
                          : AppColors.donation,
                    ),
                    const SizedBox(width: 8),
                    const Text('Donasi'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_rounded,
                      size: 18,
                      color: _tabController.index == 1
                          ? AppColors.textLight
                          : AppColors.rental,
                    ),
                    const SizedBox(width: 8),
                    const Text('Sewa'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
