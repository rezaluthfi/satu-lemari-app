// lib/features/browse/presentation/widgets/item_list_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:satulemari/core/constants/app_colors.dart'; // Import untuk warna
import 'package:satulemari/features/browse/presentation/bloc/browse_bloc.dart';
import 'package:satulemari/features/category_items/domain/entities/item_entity.dart';
import 'package:satulemari/features/home/presentation/widgets/home_shimmer.dart';
import 'package:satulemari/shared/widgets/empty_state-widget.dart'; // Import widget empty state
import 'package:satulemari/shared/widgets/network_error_widget.dart'; // Import widget network error
import 'package:satulemari/shared/widgets/product_card.dart';

class ItemListView extends StatelessWidget {
  final String type; // 'donation' or 'rental'
  const ItemListView({super.key, required this.type});

  Future<void> _onRefresh(BuildContext context) async {
    context.read<BrowseBloc>().add(BrowseDataFetched());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrowseBloc, BrowseState>(
      builder: (context, state) {
        // Pilih data dan status berdasarkan tipe tab
        final BrowseStatus status =
            type == 'donation' ? state.donationStatus : state.rentalStatus;
        final List<Item> items =
            type == 'donation' ? state.donationItems : state.rentalItems;
        final String? error =
            type == 'donation' ? state.donationError : state.rentalError;

        // --- PERBAIKAN UTAMA DIMULAI DI SINI ---

        // Kondisi Loading atau Initial
        if (status == BrowseStatus.loading || status == BrowseStatus.initial) {
          // Tetap gunakan shimmer, tapi pastikan bisa di-scroll jika diperlukan
          // oleh parent-nya (TabBarView).
          return const SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: PersonalizedGridShimmer(),
          );
        }

        // Kondisi Error
        if (status == BrowseStatus.error) {
          // Gunakan CustomScrollView agar bisa menempatkan widget di tengah
          // tanpa melanggar aturan viewport.
          return CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: NetworkErrorWidget(
                  message: error ?? 'Terjadi kesalahan tidak diketahui.',
                  onRetry: () => _onRefresh(context),
                ),
              ),
            ],
          );
        }

        // Kondisi Sukses tapi Data Kosong
        if (items.isEmpty) {
          // Sama seperti error, gunakan CustomScrollView untuk state kosong.
          return CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyStateWidget(
                  title: 'Tidak Ada Item',
                  icon: Icons.search_off_rounded,
                  message: 'Tidak ada item yang ditemukan',
                  onButtonPressed: () => _onRefresh(context),
                ),
              ),
            ],
          );
        }

        // Kondisi Sukses dengan Data
        // MasonryGridView sudah merupakan widget yang bisa di-scroll,
        // jadi aman digunakan langsung.
        return RefreshIndicator(
          onRefresh: () => _onRefresh(context),
          color: AppColors.primary, // Beri warna pada refresh indicator
          child: MasonryGridView.count(
            padding: const EdgeInsets.all(20.0), // Padding yang lebih konsisten
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
