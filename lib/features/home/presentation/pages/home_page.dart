import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/core/utils/fab_position_manager.dart';
import 'package:satulemari/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:satulemari/features/browse/presentation/bloc/browse_bloc.dart';
import 'package:satulemari/features/category_items/domain/entities/item_entity.dart';
import 'package:satulemari/features/chat/presentation/pages/chat_sessions_page.dart';
import 'package:satulemari/features/home/domain/entities/category.dart';
import 'package:satulemari/features/home/presentation/bloc/home_bloc.dart';
import 'package:satulemari/features/home/presentation/widgets/home_shimmer.dart';
import 'package:satulemari/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:satulemari/features/notification/presentation/pages/notification_page.dart';
import 'package:satulemari/shared/widgets/custom_button.dart';
import 'package:satulemari/shared/widgets/product_card.dart';
import 'package:satulemari/features/history/presentation/bloc/history_bloc.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onNavigateToBrowse;
  const HomePage({super.key, required this.onNavigateToBrowse});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // FAB position variables
  double _fabX = 0;
  double _fabY = 0;
  bool _fabInitialized = false;

  static const double _defaultPadding = 16.0;
  static const double _sectionSpacing = 24.0;
  static const double _cardRadius = 12.0;
  static const double _appBarHeight = 100.0;
  static const double _fabSize = 56.0;

  // Safe area constraints for FAB
  static const double _expandedTopSafeZone =
      120.0; // App bar + status bar (expanded)
  static const double _collapsedTopSafeZone =
      80.0; // App bar collapsed + status bar
  static const double _bottomSafeZone = 64.0; // Bottom navigation area
  static const double _sidePadding = 16.0;

  // Variabel untuk tracking scroll position
  double _currentTopSafeZone = _expandedTopSafeZone;
  bool _isAppBarCollapsed = false;

  // FAB Position Manager
  final FabPositionManager _positionManager = FabPositionManager();

  // Map untuk ikon kategori
  final Map<String, IconData> _categoryIcons = {
    'aksesoris': Icons.watch,
    'alas kaki': Icons.snowshoeing,
    'celana': Icons.style_outlined,
    'pakaian anak': Icons.child_care,
    'pakaian formal': Icons.business_center,
    'pakaian kasual': Icons.weekend,
    'pakaian luar': Icons.ac_unit,
    'pakaian olahraga': Icons.sports_soccer,
    'pakaian tradisional': Icons.fort,
  };

  // Helper Method untuk mendapatkan ikon
  IconData _getIconForCategory(String categoryName) {
    // Mengubah nama kategori menjadi lowercase untuk pencocokan yang tidak case-sensitive
    final normalizedName = categoryName.toLowerCase();
    return _categoryIcons[normalizedName] ?? Icons.category;
  }

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
    _fetchInitialData();
    _setupFCMListener();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    if (_fabInitialized) {
      _positionManager.savePosition(
        FabPositionManager.homePageKey,
        _fabX,
        _fabY,
      );
    }
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      const double collapseThreshold = _appBarHeight - 56.0;
      final bool shouldBeCollapsed = _scrollController.hasClients &&
          _scrollController.offset > collapseThreshold;
      if (shouldBeCollapsed != _isAppBarCollapsed) {
        setState(() {
          _isAppBarCollapsed = shouldBeCollapsed;
          _currentTopSafeZone =
              _isAppBarCollapsed ? _collapsedTopSafeZone : _expandedTopSafeZone;
        });
        if (_fabInitialized) {
          _updateFabPositionForTopSafeZoneChange();
        }
      }
    });
  }

  void _updateFabPositionForTopSafeZoneChange() {
    final screenSize = MediaQuery.of(context).size;
    if (_fabY < _expandedTopSafeZone) {
      setState(() {
        _fabY = _fabY.clamp(
          _currentTopSafeZone,
          screenSize.height - _bottomSafeZone - _fabSize,
        );
      });
      _positionManager.savePosition(
        FabPositionManager.homePageKey,
        _fabX,
        _fabY,
      );
    }
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

  void _handleSearchSubmitted(String query) {
    if (query.trim().isEmpty) return;
    context.read<BrowseBloc>().add(SearchTermChanged(query.trim()));
    widget.onNavigateToBrowse();
    _searchController.clear();
    FocusScope.of(context).unfocus();
  }

  void _initializeFabPosition() {
    if (!_fabInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final screenSize = MediaQuery.of(context).size;
          final savedPosition = _positionManager.getPosition(
            FabPositionManager.homePageKey,
          );
          setState(() {
            if (savedPosition != null) {
              _fabX = savedPosition.x.clamp(
                _sidePadding,
                screenSize.width - _fabSize - _sidePadding,
              );
              _fabY = savedPosition.y.clamp(
                _currentTopSafeZone,
                screenSize.height - _bottomSafeZone - _fabSize,
              );
            } else {
              final defaultPosition = _positionManager.getDefaultPosition(
                FabPositionManager.homePageKey,
                screenSize.width,
                screenSize.height,
              );
              _fabX = defaultPosition.x;
              _fabY = defaultPosition.y.clamp(
                _currentTopSafeZone,
                screenSize.height - _bottomSafeZone - _fabSize,
              );
            }
            _fabInitialized = true;
          });
        }
      });
    }
  }

  void _onFabPanUpdate(DragUpdateDetails details) {
    final screenSize = MediaQuery.of(context).size;
    setState(() {
      _fabX = (_fabX + details.delta.dx).clamp(
        _sidePadding,
        screenSize.width - _fabSize - _sidePadding,
      );
      _fabY = (_fabY + details.delta.dy).clamp(
        _currentTopSafeZone,
        screenSize.height - _bottomSafeZone - _fabSize,
      );
    });
    _positionManager.savePosition(
      FabPositionManager.homePageKey,
      _fabX,
      _fabY,
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _initializeFabPosition();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              context.read<HomeBloc>().add(FetchAllHomeData());
              context.read<NotificationBloc>().add(FetchNotificationStats());
            },
            color: AppColors.primary,
            child: CustomScrollView(
              controller: _scrollController,
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
          if (_fabInitialized)
            Positioned(
              left: _fabX,
              top: _fabY,
              child: GestureDetector(
                onPanUpdate: _onFabPanUpdate,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatSessionsPage(),
                      ),
                    );
                  },
                  backgroundColor: AppColors.primary,
                  elevation: 6,
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrendingCarousel(List<Item> items) {
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
    const double carouselHeight = 300;
    return SizedBox(
      height: carouselHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: _defaultPadding),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return SizedBox(
            width: screenWidth * 0.45,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ProductCard(item: item, isCarousel: true),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPersonalizedGrid(List<Item> items) {
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
        return ProductCard(item: item);
      },
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      floating: false,
      snap: false,
      expandedHeight: _appBarHeight,
      collapsedHeight: 56.0,
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
          title: LayoutBuilder(
            builder: (context, constraints) {
              final isCollapsed = constraints.biggest.height <= 80;
              if (isCollapsed) {
                return _buildCollapsedGreeting();
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
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
            decoration: const InputDecoration(
              hintText: 'Cari kemeja, hoodie, atau lainnya...',
              hintStyle: TextStyle(
                color: AppColors.textHint,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.textHint,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
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

  Widget _buildCollapsedGreeting() {
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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

  // --- PERUBAHAN 3: Sesuaikan _buildCategoryCard ---
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
              // Gunakan helper method untuk mendapatkan ikon dinamis
              child: Icon(
                _getIconForCategory(category.name),
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
}
