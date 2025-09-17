import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/features/browse/presentation/bloc/browse_bloc.dart';
import 'package:satulemari/features/category_items/domain/entities/item_entity.dart';
import 'package:satulemari/features/home/presentation/widgets/home_shimmer.dart';
import 'package:satulemari/shared/widgets/empty_state_widget.dart';
import 'package:satulemari/shared/widgets/network_error_widget.dart';
import 'package:satulemari/shared/widgets/product_card.dart';

class ItemListView extends StatefulWidget {
  final String type; // 'all', 'donation', 'rental', or 'thrifting'
  const ItemListView({super.key, required this.type});

  @override
  State<ItemListView> createState() => _ItemListViewState();
}

class _ItemListViewState extends State<ItemListView> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = context.read<BrowseBloc>().state;
    if (_isBottom && !state.isLoadingMore && !state.hasReachedEnd) {
      context.read<BrowseBloc>().add(LoadMoreItems(widget.type));
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Trigger load more sedikit lebih awal untuk pengalaman yang lebih mulus
    return currentScroll >= (maxScroll * 0.9);
  }

  void _retrySearch(BuildContext context) {
    context.read<BrowseBloc>().add(BrowseDataFetched());
  }

  void _resetSearch(BuildContext context) {
    context.read<BrowseBloc>().add(SearchCleared());
  }

  Future<void> _onRefresh() async {
    // Refresh selalu mengambil semua data dari awal
    context.read<BrowseBloc>().add(RefreshItems(widget.type));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrowseBloc, BrowseState>(
      builder: (context, state) {
        // Logika baru untuk memilih data yang akan ditampilkan
        List<Item> itemsToDisplay;
        switch (widget.type) {
          case 'donation':
            itemsToDisplay = state.donationItems;
            break;
          case 'rental':
            itemsToDisplay = state.rentalItems;
            break;
          case 'thrifting':
            itemsToDisplay = state.thriftingItems;
            break;
          case 'all':
          default:
            // Gabungkan semua list untuk tampilan 'Semua'
            itemsToDisplay = [
              ...state.donationItems,
              ...state.rentalItems,
              ...state.thriftingItems,
            ];
            // KODE YANG DIPERBAIKI: Mengurutkan list gabungan
            itemsToDisplay.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            break;
        }

        // Handle status loading awal (saat aplikasi pertama kali dibuka/setelah search)
        if (state.status == BrowseStatus.loading) {
          return const SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: PersonalizedGridShimmer(),
          );
        }

        // Handle error global
        if (state.status == BrowseStatus.error) {
          return CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: NetworkErrorWidget(
                  message: state.error ?? 'Terjadi kesalahan tidak diketahui.',
                  onRetry: () => _retrySearch(context),
                ),
              ),
            ],
          );
        }

        // Handle kondisi kosong setelah data berhasil diambil
        if (state.status == BrowseStatus.success && itemsToDisplay.isEmpty) {
          return CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyStateWidget(
                  title: 'Yah, Barang Tidak Ditemukan',
                  icon: Icons.search_off_rounded,
                  message:
                      'Coba gunakan kata kunci atau filter lain untuk menemukan barang impianmu.',
                  buttonText: 'Reset Pencarian',
                  onButtonPressed: () => _resetSearch(context),
                ),
              ),
            ],
          );
        }

        // Tampilkan grid jika ada item
        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primary,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(20.0),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childCount: itemsToDisplay.length,
                  itemBuilder: (context, index) {
                    final item = itemsToDisplay[index];
                    return ProductCard(item: item);
                  },
                ),
              ),
              // Tampilkan loading indicator di bawah saat load more
              if (state.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
