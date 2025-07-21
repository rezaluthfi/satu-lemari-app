part of 'home_bloc.dart';

enum DataStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  final DataStatus categoriesStatus;
  final List<Category> categories;
  final String? categoriesError;

  final DataStatus trendingStatus;
  final List<Item> trendingItems;
  final String? trendingError;

  final DataStatus personalizedStatus;
  final List<Item> personalizedItems;
  final String? personalizedError;

  const HomeState({
    this.categoriesStatus = DataStatus.initial,
    this.categories = const [],
    this.categoriesError,
    this.trendingStatus = DataStatus.initial,
    this.trendingItems = const [],
    this.trendingError,
    this.personalizedStatus = DataStatus.initial,
    this.personalizedItems = const [],
    this.personalizedError,
  });

  HomeState copyWith({
    DataStatus? categoriesStatus,
    List<Category>? categories,
    String? categoriesError,
    DataStatus? trendingStatus,
    List<Item>? trendingItems,
    String? trendingError,
    DataStatus? personalizedStatus,
    List<Item>? personalizedItems,
    String? personalizedError,
  }) {
    return HomeState(
      categoriesStatus: categoriesStatus ?? this.categoriesStatus,
      categories: categories ?? this.categories,
      categoriesError: categoriesError ?? this.categoriesError,
      trendingStatus: trendingStatus ?? this.trendingStatus,
      trendingItems: trendingItems ?? this.trendingItems,
      trendingError: trendingError ?? this.trendingError,
      personalizedStatus: personalizedStatus ?? this.personalizedStatus,
      personalizedItems: personalizedItems ?? this.personalizedItems,
      personalizedError: personalizedError ?? this.personalizedError,
    );
  }

  @override
  List<Object?> get props => [
        categoriesStatus,
        categories,
        categoriesError,
        trendingStatus,
        trendingItems,
        trendingError,
        personalizedStatus,
        personalizedItems,
        personalizedError,
      ];
}
