import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/features/browse/presentation/bloc/browse_bloc.dart';
import 'package:satulemari/features/browse/presentation/widgets/filter_bottom_sheet.dart';
import 'package:satulemari/features/browse/presentation/widgets/item_list_view.dart';
import 'package:satulemari/features/home/presentation/bloc/home_bloc.dart';
import 'dart:ui';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class BrowsePage extends StatefulWidget {
  const BrowsePage({super.key});

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _hintText = 'Cari fashion kesukaanmu...';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    final browseBloc = context.read<BrowseBloc>();
    _searchController.text = browseBloc.state.query;
    _tabController = TabController(
      initialIndex: browseBloc.state.activeTab == 'donation' ? 0 : 1,
      length: 2,
      vsync: this,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        browseBloc.add(TabChanged(_tabController.index));
      }
    });
    if (browseBloc.state.donationStatus == BrowseStatus.initial &&
        browseBloc.state.rentalStatus == BrowseStatus.initial) {
      browseBloc.add(BrowseDataFetched());
    }
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted && !_searchFocusNode.hasFocus) {
            context.read<BrowseBloc>().add(const SuggestionsRequested(''));
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _speech.stop();
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            setState(() {
              _isListening = false;
              _hintText = 'Cari fashion kesukaanmu...';
            });
            _speech.stop();
            final lastWords = _speech.lastRecognizedWords;
            if (lastWords.isNotEmpty) {
              _searchFocusNode.unfocus();
              context
                  .read<BrowseBloc>()
                  .add(IntentAnalysisAndSearchRequested(lastWords));
            }
          }
        },
        onError: (val) {
          setState(() {
            _isListening = false;
            _hintText = 'Coba lagi...';
          });
          _speech.stop();
        },
      );
      if (available) {
        setState(() {
          _isListening = true;
          _hintText = 'Aku mendengarkan...';
        });
        _speech.listen(
          localeId: 'id_ID',
          onResult: (val) {},
        );
      }
    } else {
      setState(() {
        _isListening = false;
        _hintText = 'Cari fashion kesukaanmu...';
      });
      _speech.stop();
    }
  }

  void _showFilterBottomSheet() {
    _searchFocusNode.unfocus();
    final homeState = context.read<HomeBloc>().state;
    final browseState = context.read<BrowseBloc>().state;
    if (homeState.categoriesStatus != DataStatus.loaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data kategori belum siap. Coba lagi nanti.'),
          backgroundColor: AppColors.warning,
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
          isRentalTab: browseState.activeTab == 'rental',
          activeCategoryId: browseState.categoryId,
          activeSize: browseState.size,
          activeSortBy: browseState.sortBy,
          activeSortOrder: browseState.sortOrder,
          activeCity: browseState.city,
          activeMinPrice: browseState.minPrice,
          activeMaxPrice: browseState.maxPrice,
        );
      },
    ).then((result) {
      if (result != null) {
        context.read<BrowseBloc>().add(
              FilterApplied(
                categoryId: result.categoryId,
                size: result.size,
                sortBy: result.sortBy,
                sortOrder: result.sortOrder,
                city: result.city,
                minPrice: result.minPrice,
                maxPrice: result.maxPrice,
              ),
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Jelajahi',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 28,
                letterSpacing: -0.5)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark),
        centerTitle: false,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<BrowseBloc, BrowseState>(
            listenWhen: (previous, current) => previous.query != current.query,
            listener: (context, state) {
              if (_searchController.text != state.query) {
                _searchController.text = state.query;
                _searchController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _searchController.text.length));
              }
            },
          ),
          BlocListener<BrowseBloc, BrowseState>(
            listener: (context, state) {
              if (state is PriceFilterIgnoredNotification) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(children: [
                      Icon(Icons.info_outline_rounded,
                          color: Colors.white, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                          child: Text(
                              'Filter harga/urutan harga diabaikan untuk Donasi.'))
                    ]),
                    backgroundColor: AppColors.info,
                  ),
                );
              }
            },
          ),
        ],
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  color: AppColors.surface,
                  child: Column(
                    children: [
                      _buildSearchTextField(),
                      _buildActiveFiltersSection(),
                      _buildTabSection(),
                    ],
                  ),
                ),
                Container(height: 1, color: AppColors.divider.withOpacity(0.3)),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      ItemListView(type: 'donation'),
                      ItemListView(type: 'rental'),
                    ],
                  ),
                ),
              ],
            ),
            _buildSuggestionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTextField() {
    return BlocBuilder<BrowseBloc, BrowseState>(
      buildWhen: (prev, curr) =>
          prev.query != curr.query ||
          prev.categoryId != curr.categoryId ||
          prev.size != curr.size ||
          prev.sortBy != curr.sortBy ||
          prev.city != curr.city ||
          prev.minPrice != curr.minPrice ||
          prev.maxPrice != curr.maxPrice ||
          prev.activeTab != curr.activeTab,
      builder: (context, state) {
        final hasPriceFilter = state.activeTab == 'rental' &&
            (state.minPrice != null || state.maxPrice != null);
        final hasSortByPriceFilter =
            state.activeTab == 'rental' && state.sortBy == 'price';
        final hasSortByOtherFilter =
            state.sortBy != null && state.sortBy != 'price';
        final isFilterActive = state.categoryId != null ||
            state.size != null ||
            hasSortByPriceFilter ||
            hasSortByOtherFilter ||
            (state.city != null && state.city!.isNotEmpty) ||
            hasPriceFilter;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isListening
                          ? AppColors.primary
                          : AppColors.divider.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: (query) {
                      context.read<BrowseBloc>().add(QueryChanged(query));

                      if (query.isNotEmpty) {
                        context
                            .read<BrowseBloc>()
                            .add(SuggestionsRequested(query));
                      } else {
                        context
                            .read<BrowseBloc>()
                            .add(const SuggestionsRequested(''));
                      }
                    },
                    onSubmitted: (query) {
                      if (query.isNotEmpty) {
                        context
                            .read<BrowseBloc>()
                            .add(SearchTermChanged(query));
                      }
                    },
                    style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: _hintText,
                      hintStyle: TextStyle(
                          color: _isListening
                              ? AppColors.primary
                              : AppColors.textHint,
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.textHint, size: 20),
                      suffixIcon: state.query.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchFocusNode.unfocus();
                                context.read<BrowseBloc>().add(SearchCleared());
                              },
                              child: const Icon(Icons.close_rounded,
                                  color: AppColors.textHint, size: 20))
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _listen,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _isListening
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _isListening
                            ? AppColors.primary
                            : AppColors.divider.withOpacity(0.3),
                        width: 1),
                  ),
                  child: Icon(
                      _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color:
                          _isListening ? AppColors.primary : AppColors.textHint,
                      size: 24),
                ),
              ),
              const SizedBox(width: 12),
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
                        width: 1),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.tune_rounded,
                          color: isFilterActive
                              ? AppColors.textLight
                              : AppColors.textHint,
                          size: 20),
                      if (isFilterActive)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle)),
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

  Widget _buildSuggestionContent(BrowseState state) {
    if (state.suggestionStatus == SuggestionStatus.loading) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary)),
          SizedBox(width: 16),
          Text('Aku rasa kamu suka ini, tunggu...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ]),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = state.suggestions[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _searchFocusNode.unfocus();
              context
                  .read<BrowseBloc>()
                  .add(IntentAnalysisAndSearchRequested(suggestion));
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              child: Row(children: [
                const Icon(Icons.manage_search_rounded,
                    size: 20, color: AppColors.primary),
                const SizedBox(width: 16),
                Expanded(
                    child: Text(suggestion,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500))),
                const SizedBox(width: 8),
                const Icon(Icons.north_west_rounded,
                    size: 16, color: AppColors.textHint),
              ]),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => Divider(
          height: 1,
          indent: 20,
          endIndent: 20,
          color: AppColors.divider.withOpacity(0.1)),
    );
  }

  Widget _buildSuggestionsList() {
    return BlocBuilder<BrowseBloc, BrowseState>(
      buildWhen: (prev, curr) =>
          prev.suggestionStatus != curr.suggestionStatus ||
          prev.suggestions != curr.suggestions,
      builder: (context, state) {
        final bool showSuggestions = _searchFocusNode.hasFocus &&
            (state.suggestionStatus == SuggestionStatus.loading ||
                (state.suggestionStatus == SuggestionStatus.success &&
                    state.suggestions.isNotEmpty));
        return Positioned(
          top: 64,
          left: 20,
          right: 20,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale:
                      Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                  alignment: Alignment.topCenter,
                  child: child,
                ),
              );
            },
            child: showSuggestions
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 280),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(
                            color: AppColors.divider.withOpacity(0.1),
                          ),
                        ),
                        child: _buildSuggestionContent(state),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        );
      },
    );
  }

  Widget _buildActiveFiltersSection() {
    return BlocBuilder<BrowseBloc, BrowseState>(
      buildWhen: (prev, curr) =>
          prev.categoryId != curr.categoryId ||
          prev.size != curr.size ||
          prev.sortBy != curr.sortBy ||
          prev.city != curr.city ||
          prev.minPrice != curr.minPrice ||
          prev.maxPrice != curr.maxPrice ||
          prev.activeTab != curr.activeTab,
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
        final hasPriceFilter = state.activeTab == 'rental' &&
            (state.minPrice != null || state.maxPrice != null);
        final hasSortByPriceFilter =
            state.activeTab == 'rental' && state.sortBy == 'price';
        final hasSortByOtherFilter =
            state.sortBy != null && state.sortBy != 'price';
        final hasAnyFilter = categoryName != null ||
            state.size != null ||
            hasSortByPriceFilter ||
            hasSortByOtherFilter ||
            (state.city != null && state.city!.isNotEmpty) ||
            hasPriceFilter;
        if (!hasAnyFilter) {
          return const SizedBox.shrink();
        }
        final currencyFormatter = NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
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
                              context.read<BrowseBloc>().add(FilterApplied(
                                  categoryId: null,
                                  size: state.size,
                                  sortBy: state.sortBy,
                                  sortOrder: state.sortOrder,
                                  city: state.city,
                                  minPrice: state.minPrice,
                                  maxPrice: state.maxPrice));
                            }),
                      if (state.size != null)
                        _buildFilterChip(
                            label: 'Ukuran: ${state.size}',
                            onDeleted: () {
                              context.read<BrowseBloc>().add(FilterApplied(
                                  categoryId: state.categoryId,
                                  size: null,
                                  sortBy: state.sortBy,
                                  sortOrder: state.sortOrder,
                                  city: state.city,
                                  minPrice: state.minPrice,
                                  maxPrice: state.maxPrice));
                            }),
                      if (hasSortByOtherFilter)
                        _buildFilterChip(
                            label:
                                'Urut: ${state.sortBy == 'name' ? 'Nama' : 'Terbaru'}',
                            onDeleted: () {
                              context.read<BrowseBloc>().add(FilterApplied(
                                  categoryId: state.categoryId,
                                  size: state.size,
                                  sortBy: null,
                                  sortOrder: null,
                                  city: state.city,
                                  minPrice: state.minPrice,
                                  maxPrice: state.maxPrice));
                            }),
                      if (hasSortByPriceFilter)
                        _buildFilterChip(
                            label: 'Urut: Harga',
                            onDeleted: () {
                              context.read<BrowseBloc>().add(FilterApplied(
                                  categoryId: state.categoryId,
                                  size: state.size,
                                  sortBy: null,
                                  sortOrder: null,
                                  city: state.city,
                                  minPrice: state.minPrice,
                                  maxPrice: state.maxPrice));
                            }),
                      if (state.city != null && state.city!.isNotEmpty)
                        _buildFilterChip(
                            label: 'Kota: ${state.city}',
                            onDeleted: () {
                              context.read<BrowseBloc>().add(FilterApplied(
                                  categoryId: state.categoryId,
                                  size: state.size,
                                  sortBy: state.sortBy,
                                  sortOrder: state.sortOrder,
                                  city: null,
                                  minPrice: state.minPrice,
                                  maxPrice: state.maxPrice));
                            }),
                      if (hasPriceFilter)
                        _buildFilterChip(
                            label:
                                'Harga: ${state.minPrice != null ? currencyFormatter.format(state.minPrice) : '0'} - ${state.maxPrice != null ? currencyFormatter.format(state.maxPrice) : '∞'}',
                            onDeleted: () {
                              context.read<BrowseBloc>().add(FilterApplied(
                                  categoryId: state.categoryId,
                                  size: state.size,
                                  sortBy: state.sortBy,
                                  sortOrder: state.sortOrder,
                                  city: state.city,
                                  minPrice: null,
                                  maxPrice: null));
                            }),
                    ],
                  ),
                ),
              ),
              if (hasAnyFilter) ...[
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    context.read<BrowseBloc>().add(ResetFilters());
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.error.withOpacity(0.5), width: 1)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded,
                            size: 16, color: AppColors.error),
                        SizedBox(width: 4),
                        Text('Reset',
                            style: TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
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
                color: AppColors.primary),
            labelColor: AppColors.textLight,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.all(2),
            tabs: [
              Tab(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.favorite_rounded,
                      size: 18,
                      color: _tabController.index == 0
                          ? AppColors.textLight
                          : AppColors.donation),
                  const SizedBox(width: 8),
                  const Text('Donasi'),
                ]),
              ),
              Tab(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.shopping_bag_rounded,
                      size: 18,
                      color: _tabController.index == 1
                          ? AppColors.textLight
                          : AppColors.rental),
                  const SizedBox(width: 8),
                  const Text('Sewa'),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(
      {required String label, required VoidCallback onDeleted}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: AppColors.primary.withOpacity(0.5), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDeleted,
              child: const Icon(Icons.close_rounded,
                  size: 16, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
