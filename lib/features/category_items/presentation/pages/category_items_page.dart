import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/core/di/injection.dart';
import 'package:satulemari/features/category_items/presentation/bloc/category_items_bloc.dart';
import 'package:satulemari/features/home/domain/entities/category.dart';
import 'package:satulemari/features/home/presentation/widgets/home_shimmer.dart';
import 'package:satulemari/shared/widgets/product_card.dart';

class CategoryItemsPage extends StatelessWidget {
  const CategoryItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final category = ModalRoute.of(context)!.settings.arguments as Category;

    return BlocProvider(
      create: (context) =>
          sl<CategoryItemsBloc>()..add(FetchCategoryItems(category.id)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(category.name),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          elevation: 0,
        ),
        body: BlocBuilder<CategoryItemsBloc, CategoryItemsState>(
          builder: (context, state) {
            if (state is CategoryItemsLoading ||
                state is CategoryItemsInitial) {
              return const SingleChildScrollView(
                  child: PersonalizedGridShimmer());
            }
            if (state is CategoryItemsError) {
              return Center(child: Text(state.message));
            }
            if (state is CategoryItemsLoaded) {
              if (state.items.isEmpty) {
                return const Center(
                  child: Text("Belum ada item di kategori ini."),
                );
              }
              return MasonryGridView.count(
                padding: const EdgeInsets.all(16.0),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return ProductCard(item: item);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
