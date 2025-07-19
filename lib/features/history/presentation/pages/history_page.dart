import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/features/history/presentation/bloc/history_bloc.dart';
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

    // Fetch data untuk tab pertama saat halaman dibuka
    context.read<HistoryBloc>().add(const FetchHistory(type: 'donation'));

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final type = _tabController.index == 0 ? 'donation' : 'rental';

      // Fetch data saat tab diganti HANYA JIKA belum pernah dimuat
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
          // Header Section with Tabs
          Container(
            color: AppColors.surface,
            child: Column(
              children: [
                _buildTabSection(),
              ],
            ),
          ),
          // Divider
          Container(
            height: 1,
            color: AppColors.divider.withOpacity(0.3),
          ),
          // Content Section
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                RequestListView(type: 'donation'),
                RequestListView(type: 'rental'),
              ],
            ),
          ),
        ],
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
