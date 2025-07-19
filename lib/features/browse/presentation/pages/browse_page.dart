import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/features/browse/presentation/bloc/browse_bloc.dart';
import 'package:satulemari/features/browse/presentation/widgets/filter_bottom_sheet.dart';
import 'package:satulemari/features/browse/presentation/widgets/item_list_view.dart';
import 'package:satulemari/features/home/presentation/bloc/home_bloc.dart';

class BrowsePage extends StatefulWidget {
  const BrowsePage({super.key});

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final browseBloc = context.read<BrowseBloc>();

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      _searchController.clear();
      browseBloc.add(TabChanged(_tabController.index));
    });

    _searchController.addListener(() {
      if (_showClearButton != _searchController.text.isNotEmpty) {
        setState(() {
          _showClearButton = _searchController.text.isNotEmpty;
        });
      }
    });

    if (browseBloc.state.status == BrowseStatus.initial) {
      browseBloc.add(BrowseDataFetched());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    final homeState = context.read<HomeBloc>().state;
    final browseState = context.read<BrowseBloc>().state;

    if (homeState.categoriesStatus != DataStatus.loaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Data kategori belum siap. Coba lagi nanti.'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    showModalBottomSheet<FilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return FilterBottomSheet(
          categories: homeState.categories,
          activeCategoryId: browseState.categoryId,
          activeSize: browseState.size,
        );
      },
    ).then((result) {
      if (result != null) {
        print(
            'Filter result received: categoryId=${result.categoryId}, size=${result.size}');
        context.read<BrowseBloc>().add(
              FilterApplied(
                categoryId: result.categoryId,
                size: result.size,
              ),
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Jelajahi',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 28,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Header Section with Search and Filters
          Container(
            color: AppColors.surface,
            child: Column(
              children: [
                _buildSearchSection(),
                _buildActiveFiltersSection(),
                _buildTabSection(),
              ],
            ),
          ),
          // Divider
          Container(
            height: 1,
            color: AppColors.divider.withOpacity(0.3),
          ),
          // Content Section
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                ItemListView(type: 'donation'),
                ItemListView(type: 'rental'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return BlocBuilder<BrowseBloc, BrowseState>(
      builder: (context, state) {
        final isFilterActive = state.categoryId != null || state.size != null;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Row(
            children: [
              // Search Field
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.divider.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (query) {
                      if (query.isEmpty) {
                        context.read<BrowseBloc>().add(SearchCleared());
                      } else {
                        context
                            .read<BrowseBloc>()
                            .add(SearchTermChanged(query));
                      }
                    },
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari pakaian...',
                      hintStyle: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppColors.textHint,
                        size: 20,
                      ),
                      suffixIcon: _showClearButton
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                context.read<BrowseBloc>().add(SearchCleared());
                              },
                              child: Icon(
                                Icons.close_rounded,
                                color: AppColors.textHint,
                                size: 20,
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Filter Button
              GestureDetector(
                onTap: _showFilterBottomSheet,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isFilterActive
                        ? AppColors.primary
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isFilterActive
                          ? AppColors.primary
                          : AppColors.divider.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        color: isFilterActive
                            ? AppColors.textLight
                            : AppColors.textHint,
                        size: 20,
                      ),
                      if (isFilterActive)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveFiltersSection() {
    return BlocBuilder<BrowseBloc, BrowseState>(
      builder: (context, state) {
        final homeState = context.read<HomeBloc>().state;
        String? categoryName;

        if (homeState.categoriesStatus == DataStatus.loaded &&
            state.categoryId != null) {
          try {
            categoryName = homeState.categories
                .firstWhere((cat) => cat.id == state.categoryId)
                .name;
          } catch (e) {
            categoryName = null;
          }
        }

        if (categoryName == null && state.size == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (categoryName != null)
                        _buildFilterChip(
                          label: categoryName,
                          onDeleted: () {
                            _searchController.clear();
                            context.read<BrowseBloc>().add(FilterApplied(
                                categoryId: null, size: state.size));
                          },
                        ),
                      if (state.size != null)
                        _buildFilterChip(
                          label: 'Ukuran ${state.size}',
                          onDeleted: () {
                            _searchController.clear();
                            context.read<BrowseBloc>().add(FilterApplied(
                                categoryId: state.categoryId, size: null));
                          },
                        ),
                    ],
                  ),
                ),
              ),
              if (categoryName != null || state.size != null) ...[
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    context.read<BrowseBloc>().add(ResetFilters());
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          size: 16,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Reset',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(24),
      ),
      child: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          return TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: AppColors.primary,
            ),
            labelColor: AppColors.textLight,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.all(2),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      size: 18,
                      color: _tabController.index == 0
                          ? AppColors.textLight
                          : AppColors.donation,
                    ),
                    const SizedBox(width: 8),
                    const Text('Donasi'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_rounded,
                      size: 18,
                      color: _tabController.index == 1
                          ? AppColors.textLight
                          : AppColors.rental,
                    ),
                    const SizedBox(width: 8),
                    const Text('Sewa'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDeleted,
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
