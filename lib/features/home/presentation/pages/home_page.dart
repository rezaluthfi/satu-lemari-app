import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:satulemari/features/browse/presentation/bloc/browse_bloc.dart';
import 'package:satulemari/features/home/domain/entities/category.dart';
import 'package:satulemari/features/home/domain/entities/recommendation.dart';
import 'package:satulemari/features/home/presentation/bloc/home_bloc.dart';
import 'package:satulemari/features/home/presentation/widgets/home_shimmer.dart';
import 'package:satulemari/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:satulemari/features/notification/presentation/pages/notification_page.dart';
import 'package:satulemari/shared/widgets/custom_button.dart';
import 'package:satulemari/shared/widgets/product_card.dart';
import 'package:satulemari/features/history/presentation/bloc/history_bloc.dart';

class HomePage extends StatefulWidget {
  // Callback untuk memberitahu MainPage agar pindah tab
  final VoidCallback onNavigateToBrowse;

  const HomePage({super.key, required this.onNavigateToBrowse});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  // Controller untuk search bar
  late TextEditingController _searchController;

  static const double _defaultPadding = 16.0;
  static const double _sectionSpacing = 24.0;
  static const double _cardRadius = 12.0;
  static const double _appBarHeight = 100.0;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _fetchInitialData();
    _setupFCMListener();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchInitialData() {
    final homeBloc = context.read<HomeBloc>();
    if (homeBloc.state.categoriesStatus == DataStatus.initial) {
      homeBloc.add(FetchAllHomeData());
    }
    context.read<NotificationBloc>().add(FetchNotificationStats());
  }

  void _setupFCMListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (mounted) {
        context.read<NotificationBloc>().add(FetchNotificationStats());
      }
    });
  }

  // Fungsi untuk menangani submit pencarian dari TextField
  void _handleSearchSubmitted(String query) {
    if (query.trim().isEmpty) return;

    // 1. Kirim event ke BrowseBloc untuk memulai pencarian
    context.read<BrowseBloc>().add(SearchTermChanged(query.trim()));

    // 2. Panggil callback untuk berpindah ke tab Browse
    widget.onNavigateToBrowse();

    // 3. Kosongkan field di HomePage agar siap untuk pencarian berikutnya
    _searchController.clear();
    // 4. Hilangkan fokus dari TextField
    FocusScope.of(context).unfocus();
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
          context.read<NotificationBloc>().add(FetchNotificationStats());
        },
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            _buildSearchBar(),
            _buildPromotionalBanner(),
            _buildCategories(),
            _buildTrending(),
            _buildPersonalized(),
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      floating: true,
      expandedHeight: _appBarHeight,
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
          background: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  _defaultPadding, 8, _defaultPadding, _defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildGreeting(),
                  const SizedBox(height: 4),
                  const Flexible(
                    child: Text(
                      'Temukan fashion terbaikmu hari ini',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.primary,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: BlocBuilder<NotificationBloc, NotificationState>(
            buildWhen: (previous, current) => previous.stats != current.stats,
            builder: (context, state) {
              final hasUnread = (state.stats?.unreadCount ?? 0) > 0;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: BlocProvider.of<NotificationBloc>(context),
                            child: const NotificationPage(),
                          ),
                        ),
                      );
                      if (mounted) {
                        context
                            .read<NotificationBloc>()
                            .add(FetchNotificationStats());
                        context
                            .read<HistoryBloc>()
                            .add(const FetchHistory(type: 'donation'));
                        context
                            .read<HistoryBloc>()
                            .add(const FetchHistory(type: 'rental'));
                      }
                    },
                    icon: const Icon(
                      Icons.notifications_none_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  if (hasUnread)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.premium,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            _defaultPadding, _defaultPadding, _defaultPadding, 0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_cardRadius),
            border: Border.all(color: AppColors.divider, width: 1),
          ),
          child: TextField(
            controller: _searchController,
            onSubmitted: _handleSearchSubmitted,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Cari kemeja, hoodie, atau lainnya...',
              hintStyle: const TextStyle(
                color: AppColors.textHint,
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textHint,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromotionalBanner() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(_defaultPadding),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_cardRadius),
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
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                right: 30,
                bottom: -10,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(_defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Dapatkan Diskon 50%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const Flexible(
                      child: Text(
                        'Untuk semua item fashion premium',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Lihat Sekarang',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SliverList(
      delegate: SliverChildListDelegate([
        const SizedBox(height: _sectionSpacing),
        _buildSectionHeader(
          'Jelajahi Kategori',
          subtitle: 'Pilih kategori favoritmu',
        ),
        BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (p, c) => p.categoriesStatus != c.categoriesStatus,
          builder: (context, state) {
            switch (state.categoriesStatus) {
              case DataStatus.loading:
              case DataStatus.initial:
                return const CategoryGridShimmer();
              case DataStatus.loaded:
                return _buildCategoryGrid(state.categories);
              case DataStatus.error:
                return _buildSectionError(
                  state.categoriesError ?? 'Gagal memuat kategori',
                  () => context.read<HomeBloc>().add(FetchCategories()),
                );
            }
          },
        ),
      ]),
    );
  }

  Widget _buildTrending() {
    return SliverList(
      delegate: SliverChildListDelegate([
        const SizedBox(height: _sectionSpacing),
        _buildSectionHeader(
          'Lagi Tren',
          subtitle: 'Item populer minggu ini',
        ),
        const SizedBox(height: 16),
        BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (p, c) => p.trendingStatus != c.trendingStatus,
          builder: (context, state) {
            switch (state.trendingStatus) {
              case DataStatus.loading:
              case DataStatus.initial:
                return const TrendingCarouselShimmer();
              case DataStatus.loaded:
                return _buildTrendingCarousel(state.trendingItems);
              case DataStatus.error:
                return _buildSectionError(
                  state.trendingError ?? 'Gagal memuat item tren',
                  () => context.read<HomeBloc>().add(FetchTrendingItems()),
                );
            }
          },
        ),
      ]),
    );
  }

  Widget _buildPersonalized() {
    return SliverList(
      delegate: SliverChildListDelegate([
        const SizedBox(height: _sectionSpacing),
        _buildSectionHeader(
          'Spesial Untukmu',
          subtitle: 'Rekomendasi berdasarkan preferensimu',
        ),
        const SizedBox(height: 16),
        BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (p, c) => p.personalizedStatus != c.personalizedStatus,
          builder: (context, state) {
            switch (state.personalizedStatus) {
              case DataStatus.loading:
              case DataStatus.initial:
                return const PersonalizedGridShimmer();
              case DataStatus.loaded:
                return _buildPersonalizedGrid(state.personalizedItems);
              case DataStatus.error:
                return _buildSectionError(
                  state.personalizedError ?? 'Gagal memuat rekomendasi',
                  () => context.read<HomeBloc>().add(FetchPersonalizedItems()),
                );
            }
          },
        ),
      ]),
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
        return Flexible(
          child: Text(
            'Halo, $name!',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionError(String message, VoidCallback onRetry) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: _defaultPadding),
      padding: const EdgeInsets.all(_defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Coba Lagi',
              onPressed: onRetry,
              type: ButtonType.outline,
              height: 36,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(List<Category> categories) {
    if (categories.isEmpty) {
      return Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: _defaultPadding),
        child: const Center(
          child: Text(
            "Kategori tidak ditemukan.",
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: _defaultPadding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount =
              (constraints.maxWidth / 80).floor().clamp(3, 5);
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryCard(category);
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/category-items', arguments: category);
      },
      borderRadius: BorderRadius.circular(_cardRadius),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_cardRadius),
          border: Border.all(color: AppColors.divider, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_offer_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  category.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingCarousel(List<Recommendation> items) {
    if (items.isEmpty) {
      return Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: _defaultPadding),
        child: const Center(
          child: Text(
            "Tidak ada item tren saat ini.",
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.48;
    final cardHeight = cardWidth * 1.5;

    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: _defaultPadding),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return SizedBox(
            width: cardWidth,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ProductCard(recommendation: item, isCarousel: true),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPersonalizedGrid(List<Recommendation> items) {
    if (items.isEmpty) {
      return Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: _defaultPadding),
        child: const Center(
          child: Text(
            "Belum ada rekomendasi untukmu.",
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return MasonryGridView.count(
      padding: const EdgeInsets.symmetric(horizontal: _defaultPadding),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
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
