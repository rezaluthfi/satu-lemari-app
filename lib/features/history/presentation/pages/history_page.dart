import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/features/history/domain/entities/request_item.dart';
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

    _tabController = TabController(length: 3, vsync: this);

    final historyBloc = context.read<HistoryBloc>();

    _initialFetch(historyBloc);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final types = ['donation', 'rental', 'thrifting'];
      final selectedType = types[_tabController.index];

      _fetchDataForTab(historyBloc, selectedType);
    });
  }

  void _initialFetch(HistoryBloc bloc) {
    if (bloc.state.donationStatus == HistoryStatus.initial ||
        bloc.state.rentalStatus == HistoryStatus.initial ||
        bloc.state.thriftingStatus == HistoryStatus.initial) {
      // Fetch data untuk tab yang sedang aktif pertama kali
      final types = ['donation', 'rental', 'thrifting'];
      final initialType = types[_tabController.index];
      bloc.add(FetchHistory(type: initialType));
    }
  }

  void _fetchDataForTab(HistoryBloc bloc, String type) {
    final state = bloc.state;
    switch (type) {
      case 'donation':
        if (state.donationStatus == HistoryStatus.initial) {
          bloc.add(const FetchHistory(type: 'donation'));
        }
        break;
      case 'rental':
        if (state.rentalStatus == HistoryStatus.initial) {
          bloc.add(const FetchHistory(type: 'rental'));
        }
        break;
      case 'thrifting':
        if (state.thriftingStatus == HistoryStatus.initial) {
          bloc.add(const FetchHistory(type: 'thrifting'));
        }
        break;
    }
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
          'Riwayat Transaksi',
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
                _buildHistoryView(type: 'donation'),
                _buildHistoryView(type: 'rental'),
                _buildHistoryView(type: 'thrifting'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryView({required String type}) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      buildWhen: (previous, current) {
        switch (type) {
          case 'donation':
            return previous.donationStatus != current.donationStatus ||
                previous.donationRequests != current.donationRequests;
          case 'rental':
            return previous.rentalStatus != current.rentalStatus ||
                previous.rentalRequests != current.rentalRequests;
          case 'thrifting':
            return previous.thriftingStatus != current.thriftingStatus ||
                previous.thriftingRequests != current.thriftingRequests;
          default:
            return false;
        }
      },
      builder: (context, state) {
        HistoryStatus status;
        List<RequestItem> requests;
        String? error;

        switch (type) {
          case 'donation':
            status = state.donationStatus;
            requests = state.donationRequests;
            error = state.donationError;
            break;
          case 'rental':
            status = state.rentalStatus;
            requests = state.rentalRequests;
            error = state.rentalError;
            break;
          case 'thrifting':
            status = state.thriftingStatus;
            requests = state.thriftingRequests;
            error = state.thriftingError;
            break;
          default:
            return const Center(child: Text("Tipe tidak valid."));
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<HistoryBloc>().add(RefreshHistory(type: type));
          },
          color: AppColors.primary,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (status == HistoryStatus.loading && requests.isEmpty) {
                return const HistoryListShimmer();
              }

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

              return RequestListView(
                type: type,
                requests: requests,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String type) {
    String title;
    String message;
    IconData icon;

    switch (type) {
      case 'donation':
        title = 'Belum Ada Riwayat Donasi';
        message = 'Permintaan donasi Anda akan muncul di sini.';
        icon = Icons.favorite_outline_rounded;
        break;
      case 'rental':
        title = 'Belum Ada Riwayat Sewa';
        message = 'Permintaan sewa Anda akan muncul di sini.';
        icon = Icons.shopping_bag_outlined;
        break;
      case 'thrifting':
        title = 'Belum Ada Riwayat Pembelian';
        message = 'Pembelian barang thrift Anda akan muncul di sini.';
        icon = Icons.sell_outlined;
        break;
      default:
        title = 'Kosong';
        message = 'Tidak ada data.';
        icon = Icons.inbox_outlined;
    }

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
              child: Icon(icon, size: 40, color: AppColors.textHint),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
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
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sell_rounded,
                      size: 18,
                      color: _tabController.index == 2
                          ? AppColors.textLight
                          : AppColors.thrifting,
                    ),
                    const SizedBox(width: 8),
                    const Text('Thrift'),
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
