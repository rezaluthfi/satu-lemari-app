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
  final String type; // 'donation', 'rental', or 'thrifting'
  const ItemListView({super.key, required this.type});

  @override
  State<ItemListView> createState() => _ItemListViewState();
}

class _ItemListViewState extends State<ItemListView> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

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
    if (_isBottom && !_isLoadingMore) {
      _isLoadingMore = true;
      context.read<BrowseBloc>().add(LoadMoreItems(widget.type));
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _isLoadingMore = false;
        }
      });
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _retrySearch(BuildContext context) {
    final currentQuery = context.read<BrowseBloc>().state.query;
    if (currentQuery.isNotEmpty) {
      context.read<BrowseBloc>().add(SearchTermChanged(currentQuery));
    } else {
      context.read<BrowseBloc>().add(BrowseDataFetched());
    }
  }

  void _resetSearch(BuildContext context) {
    context.read<BrowseBloc>().add(SearchCleared());
  }

  Future<void> _onRefresh() async {
    context.read<BrowseBloc>().add(RefreshItems(widget.type));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrowseBloc, BrowseState>(
      builder: (context, state) {
        // <-- PERUBAHAN UTAMA: Menggunakan switch-case untuk mengambil data yang benar
        BrowseStatus status;
        List<Item> items;
        bool isLoadingMore;
        String? error;

        switch (widget.type) {
          case 'donation':
            status = state.donationStatus;
            items = state.donationItems;
            isLoadingMore = state.donationIsLoadingMore;
            error = state.donationError;
            break;
          case 'rental':
            status = state.rentalStatus;
            items = state.rentalItems;
            isLoadingMore = state.rentalIsLoadingMore;
            error = state.rentalError;
            break;
          case 'thrifting':
            status = state.thriftingStatus;
            items = state.thriftingItems;
            isLoadingMore = state.thriftingIsLoadingMore;
            error = state.thriftingError;
            break;
          default:
            // Fallback jika tipe tidak dikenal, untuk menghindari crash
            return const Center(child: Text("Tipe tidak valid."));
        }

        if (status == BrowseStatus.loading || status == BrowseStatus.initial) {
          return const SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: PersonalizedGridShimmer(),
          );
        }

        if (status == BrowseStatus.error) {
          return CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: NetworkErrorWidget(
                  message: error ?? 'Terjadi kesalahan tidak diketahui.',
                  onRetry: () => _retrySearch(context),
                ),
              ),
            ],
          );
        }

        if (status == BrowseStatus.success && items.isEmpty) {
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
                  childCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ProductCard(item: item);
                  },
                ),
              ),
              if (isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
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
