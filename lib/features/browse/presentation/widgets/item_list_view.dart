import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:satulemari/features/browse/presentation/bloc/browse_bloc.dart';
import 'package:satulemari/features/category_items/domain/entities/item_entity.dart';
import 'package:satulemari/features/home/presentation/widgets/home_shimmer.dart';
import 'package:satulemari/shared/widgets/product_card.dart';

class ItemListView extends StatelessWidget {
  final String type; // 'donation' or 'rental'
  const ItemListView({super.key, required this.type});

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

        if (status == BrowseStatus.loading || status == BrowseStatus.initial) {
          return const SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: PersonalizedGridShimmer(),
          );
        }

        if (status == BrowseStatus.error) {
          return Center(child: Text(error ?? 'Terjadi kesalahan'));
        }

        if (items.isEmpty) {
          return const Center(child: Text('Tidak ada item yang ditemukan.'));
        }

        // Gunakan RefreshIndicator untuk pull-to-refresh
        return RefreshIndicator(
          onRefresh: () async {
            context.read<BrowseBloc>().add(BrowseDataFetched());
          },
          child: MasonryGridView.count(
            padding: const EdgeInsets.all(16.0),
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
