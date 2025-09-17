import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/features/history/presentation/bloc/history_bloc.dart';
import 'package:satulemari/features/history/presentation/widgets/history_shimmer.dart';
import 'package:satulemari/features/history/presentation/widgets/request_list_view.dart';
import 'package:satulemari/features/history/presentation/widgets/order_list_view.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _mainTabController;
  late TabController _requestSubTabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    _requestSubTabController = TabController(length: 2, vsync: this);

    // Add listener to main tab controller for better state management
    _mainTabController.addListener(() {
      if (!_mainTabController.indexIsChanging) {
        setState(() {}); // Refresh UI when tab changes
      }
    });
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _requestSubTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider.value(
      value: BlocProvider.of<HistoryBloc>(context),
      child: Scaffold(
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
        body: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) {
            // Panggil fetch awal dari sini jika diperlukan
            if (state.requestsStatus == HistoryStatus.initial &&
                state.ordersStatus == HistoryStatus.initial) {
              context.read<HistoryBloc>().add(FetchAllHistory());
            }

            return Column(
              children: [
                Container(
                  color: AppColors.surface,
                  child: Column(
                    children: [
                      _buildMainTabSection(),
                      AnimatedBuilder(
                        animation: _mainTabController,
                        builder: (context, child) {
                          return _mainTabController.index == 0
                              ? _buildRequestSubTabSection()
                              : const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 1,
                  color: AppColors.divider.withOpacity(0.3),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _mainTabController,
                    children: [
                      _buildRequestsTabContent(state),
                      _buildOrdersTab(state),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainTabSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(24),
      ),
      child: AnimatedBuilder(
        animation: _mainTabController,
        builder: (context, child) {
          return TabBar(
            controller: _mainTabController,
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
                      Icons.request_page_rounded,
                      size: 18,
                      color: _mainTabController.index == 0
                          ? AppColors.textLight
                          : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text('Permintaan'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 18,
                      color: _mainTabController.index == 1
                          ? AppColors.textLight
                          : AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    const Text('Pesanan'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRequestSubTabSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(22),
      ),
      child: AnimatedBuilder(
        animation: _requestSubTabController,
        builder: (context, child) {
          return TabBar(
            controller: _requestSubTabController,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
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
                      size: 16,
                      color: _requestSubTabController.index == 0
                          ? AppColors.donation
                          : AppColors.textHint,
                    ),
                    const SizedBox(width: 6),
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
                      size: 16,
                      color: _requestSubTabController.index == 1
                          ? AppColors.rental
                          : AppColors.textHint,
                    ),
                    const SizedBox(width: 6),
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

  Widget _buildRequestsTabContent(HistoryState state) {
    return TabBarView(
      controller: _requestSubTabController,
      children: [
        _buildRequestListView(state, 'donation'),
        _buildRequestListView(state, 'rental'),
      ],
    );
  }

  Widget _buildRequestListView(HistoryState state, String type) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HistoryBloc>().add(RefreshHistory());
      },
      color: AppColors.primary,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (state.requestsStatus == HistoryStatus.loading) {
            return const HistoryListShimmer();
          }
          if (state.requestsStatus == HistoryStatus.error) {
            return _buildErrorState(
                state.requestsError ?? 'Gagal memuat permintaan', constraints);
          }

          final filteredRequests =
              state.requests.where((req) => req.type == type).toList();

          if (filteredRequests.isEmpty) {
            return _buildEmptyState(type, constraints);
          }

          return RequestListView(type: type, requests: filteredRequests);
        },
      ),
    );
  }

  Widget _buildOrdersTab(HistoryState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HistoryBloc>().add(RefreshHistory());
      },
      color: AppColors.primary,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (state.ordersStatus == HistoryStatus.loading) {
            return const HistoryListShimmer();
          }
          if (state.ordersStatus == HistoryStatus.error) {
            return _buildErrorState(
                state.ordersError ?? 'Gagal memuat pesanan', constraints);
          }
          if (state.orders.isEmpty) {
            return _buildEmptyState('orders', constraints);
          }
          return OrderListView(orders: state.orders);
        },
      ),
    );
  }

  Widget _buildEmptyState(String type, BoxConstraints constraints) {
    String title;
    String message;
    IconData icon;
    Color iconColor;

    switch (type) {
      case 'donation':
        title = 'Belum Ada Permintaan Donasi';
        message =
            'Permintaan donasi Anda yang menunggu persetujuan akan muncul di sini.';
        icon = Icons.favorite_outline_rounded;
        iconColor = AppColors.donation;
        break;
      case 'rental':
        title = 'Belum Ada Permintaan Sewa';
        message =
            'Permintaan sewa Anda yang menunggu persetujuan akan muncul di sini.';
        icon = Icons.shopping_bag_outlined;
        iconColor = AppColors.rental;
        break;
      case 'orders':
        title = 'Belum Ada Riwayat Pesanan';
        message =
            'Semua pesanan pembelian, donasi, atau sewa Anda akan muncul di sini.';
        icon = Icons.receipt_long_outlined;
        iconColor = AppColors.warning;
        break;
      default:
        title = 'Kosong';
        message = 'Tidak ada data.';
        icon = Icons.inbox_outlined;
        iconColor = AppColors.textHint;
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Icon(
                    icon,
                    size: 40,
                    color: iconColor,
                  ),
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
                const SizedBox(height: 32),
                // Add action button for better UX
                GestureDetector(
                  onTap: () {
                    context.read<HistoryBloc>().add(RefreshHistory());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: iconColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          size: 16,
                          color: iconColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Refresh Data',
                          style: TextStyle(
                            color: iconColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, BoxConstraints constraints) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Center(
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
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    context.read<HistoryBloc>().add(FetchAllHistory());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          size: 16,
                          color: AppColors.error,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Coba Lagi',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
