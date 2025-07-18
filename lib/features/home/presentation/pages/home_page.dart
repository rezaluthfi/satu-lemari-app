import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:satulemari/features/home/domain/entities/category.dart';
import 'package:satulemari/features/home/domain/entities/recommendation.dart';
import 'package:satulemari/features/home/presentation/bloc/home_bloc.dart';
import 'package:satulemari/features/home/presentation/widgets/home_shimmer.dart';
import 'package:satulemari/shared/widgets/custom_button.dart';
import 'package:satulemari/shared/widgets/product_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    final homeBloc = context.read<HomeBloc>();
    final currentState = homeBloc.state;
    if (currentState.categoriesStatus == DataStatus.initial) {
      homeBloc.add(FetchAllHomeData());
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<HomeBloc>().add(FetchAllHomeData());
        },
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // Enhanced AppBar with gradient and better styling
            SliverAppBar(
              pinned: true,
              floating: true,
              expandedHeight: 120.0,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primaryLight,
                    ],
                  ),
                ),
                child: FlexibleSpaceBar(
                  background: Container(
                    padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGreeting(),
                        const SizedBox(height: 4),
                        const Text(
                          'Temukan fashion terbaikmu hari ini',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              backgroundColor: AppColors.primary,
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    onPressed: () {
                      // TODO: Navigasi ke halaman notifikasi
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications_none_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Enhanced Search Bar
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider, width: 1),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari kemeja, hoodie, atau lainnya...',
                      hintStyle: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 14,
                      ),
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          Icons.search_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.search_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 0,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Promotional Banner
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildPromotionalBanner(),
              ),
            ),

            // Main Content
            SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 32),
                _buildSectionHeader(context, 'Jelajahi Kategori',
                    subtitle: 'Pilih kategori favoritmu'),
                BlocBuilder<HomeBloc, HomeState>(
                  buildWhen: (p, c) => p.categoriesStatus != c.categoriesStatus,
                  builder: (context, state) {
                    switch (state.categoriesStatus) {
                      case DataStatus.loading:
                      case DataStatus.initial:
                        return const CategoryGridShimmer();
                      case DataStatus.loaded:
                        return _buildCategoryGrid(context, state.categories);
                      case DataStatus.error:
                        return _buildSectionError(
                          context,
                          state.categoriesError ?? 'Gagal memuat kategori',
                          () => context.read<HomeBloc>().add(FetchCategories()),
                        );
                    }
                  },
                ),
                const SizedBox(height: 40),
                _buildSectionHeader(context, 'Lagi Tren',
                    subtitle: 'Item populer minggu ini'),
                const SizedBox(height: 20),
                BlocBuilder<HomeBloc, HomeState>(
                  buildWhen: (p, c) => p.trendingStatus != c.trendingStatus,
                  builder: (context, state) {
                    switch (state.trendingStatus) {
                      case DataStatus.loading:
                      case DataStatus.initial:
                        return const TrendingCarouselShimmer();
                      case DataStatus.loaded:
                        return _buildTrendingCarousel(
                            context, state.trendingItems);
                      case DataStatus.error:
                        return _buildSectionError(
                          context,
                          state.trendingError ?? 'Gagal memuat item tren',
                          () => context
                              .read<HomeBloc>()
                              .add(FetchTrendingItems()),
                        );
                    }
                  },
                ),
                const SizedBox(height: 40),
                _buildSectionHeader(context, 'Spesial Untukmu',
                    subtitle: 'Rekomendasi berdasarkan preferensimu'),
                const SizedBox(height: 20),
                BlocBuilder<HomeBloc, HomeState>(
                  buildWhen: (p, c) =>
                      p.personalizedStatus != c.personalizedStatus,
                  builder: (context, state) {
                    switch (state.personalizedStatus) {
                      case DataStatus.loading:
                      case DataStatus.initial:
                        return const PersonalizedGridShimmer();
                      case DataStatus.loaded:
                        return _buildPersonalizedGrid(
                            context, state.personalizedItems);
                      case DataStatus.error:
                        return _buildSectionError(
                          context,
                          state.personalizedError ?? 'Gagal memuat rekomendasi',
                          () => context
                              .read<HomeBloc>()
                              .add(FetchPersonalizedItems()),
                        );
                    }
                  },
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String name = 'Pengguna';
        if (state is Authenticated) {
          name =
              (state.user.username != null && state.user.username!.isNotEmpty)
                  ? state.user.username!
                  : 'Pengguna';
        }
        return Text(
          'Halo, $name!',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildPromotionalBanner() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent,
            AppColors.warning,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -10,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Dapatkan Diskon 50%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Untuk semua item fashion premium',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Lihat Sekarang',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title,
      {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          TextButton(
            onPressed: () {
              // TODO: Navigate to see all
            },
            child: const Text(
              'Lihat Semua',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionError(
      BuildContext context, String message, VoidCallback onRetry) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Coba Lagi',
            onPressed: onRetry,
            type: ButtonType.outline,
            height: 32,
            fontSize: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, List<Category> categories) {
    if (categories.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            "Kategori tidak ditemukan.",
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _buildCategoryCard(context, category);
        },
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Category category) {
    return InkWell(
      onTap: () {
        // Navigate to category items page
        Navigator.pushNamed(context, '/category-items', arguments: category);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_offer_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingCarousel(
      BuildContext context, List<Recommendation> items) {
    if (items.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            "Tidak ada item tren saat ini.",
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            margin: const EdgeInsets.only(right: 16),
            child: ProductCard(recommendation: item, isCarousel: true),
          );
        },
      ),
    );
  }

  Widget _buildPersonalizedGrid(
      BuildContext context, List<Recommendation> items) {
    if (items.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            "Belum ada rekomendasi untukmu.",
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return MasonryGridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = items[index];
        return ProductCard(recommendation: item);
      },
    );
  }
}
