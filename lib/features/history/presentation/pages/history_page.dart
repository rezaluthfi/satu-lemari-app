import 'package:flutter/material.dart';
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
      appBar: AppBar(
        title: const Text('Riwayat Permintaan'),
        backgroundColor: AppColors.background,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Donasi'),
            Tab(text: 'Sewa'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          RequestListView(type: 'donation'),
          RequestListView(type: 'rental'),
        ],
      ),
    );
  }
}
