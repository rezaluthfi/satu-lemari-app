// lib/features/browse/presentation/widgets/item_list_view.dart

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
import 'package:tuple/tuple.dart'; // <-- IMPORT PACKAGE BARU

class ItemListView extends StatelessWidget {
  final String type; // 'donation' or 'rental'
  const ItemListView({super.key, required this.type});

  // Helper untuk memicu refresh/retry dengan query yang sedang aktif
  void _retrySearch(BuildContext context) {
    final currentQuery = context.read<BrowseBloc>().state.query;
    if (currentQuery.isNotEmpty) {
      context.read<BrowseBloc>().add(SearchTermChanged(currentQuery));
    } else {
      // Jika tidak ada query, fetch data awal
      context.read<BrowseBloc>().add(BrowseDataFetched());
    }
  }

  // Helper untuk mereset pencarian
  void _resetSearch(BuildContext context) {
    context.read<BrowseBloc>().add(SearchCleared());
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<BrowseBloc, BrowseState,
        Tuple2<BrowseStatus, List<Item>>>(
      // Selector ini "memilih" hanya status dan item yang relevan untuk tab ini.
      // UI HANYA akan rebuild jika nilai Tuple2 ini berubah.
      selector: (state) {
        if (type == 'donation') {
          return Tuple2(state.donationStatus, state.donationItems);
        } else {
          return Tuple2(state.rentalStatus, state.rentalItems);
        }
      },
      builder: (context, selectedState) {
        // Ambil nilai dari tuple
        final BrowseStatus status = selectedState.item1;
        final List<Item> items = selectedState.item2;

        // Kondisi Loading ditampilkan PERTAMA
        if (status == BrowseStatus.loading || status == BrowseStatus.initial) {
          return const SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: PersonalizedGridShimmer(),
          );
        }

        // Kondisi Error
        if (status == BrowseStatus.error) {
          // Ambil pesan error yang relevan dari state lengkap
          final error = type == 'donation'
              ? context.read<BrowseBloc>().state.donationError
              : context.read<BrowseBloc>().state.rentalError;

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

        // Kondisi Sukses tapi Data Kosong
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

        // Kondisi Sukses dengan Data
        return RefreshIndicator(
          onRefresh: () async => _resetSearch(context),
          color: AppColors.primary,
          child: MasonryGridView.count(
            padding: const EdgeInsets.all(20.0),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ProductCard(item: item);
            },
          ),
        );
      },
    );
  }
}
