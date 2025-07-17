import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/home/domain/entities/category.dart';
import 'package:satulemari/features/home/domain/entities/recommendation.dart';
import 'package:satulemari/features/home/domain/usecases/get_categories_usecase.dart';
import 'package:satulemari/features/home/domain/usecases/get_trending_items_usecase.dart';
import 'package:satulemari/features/home/domain/usecases/get_personalized_recommendations_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetCategoriesUseCase getCategories;
  final GetTrendingItemsUseCase getTrendingItems;
  final GetPersonalizedRecommendationsUseCase getPersonalizedRecommendations;

  HomeBloc({
    required this.getCategories,
    required this.getTrendingItems,
    required this.getPersonalizedRecommendations,
  }) : super(const HomeState()) {
    on<FetchAllHomeData>((event, emit) {
      add(FetchCategories());
      add(FetchTrendingItems());
      add(FetchPersonalizedItems());
    });

    on<FetchCategories>(_onFetchCategories);
    on<FetchTrendingItems>(_onFetchTrendingItems);
    on<FetchPersonalizedItems>(_onFetchPersonalizedItems);
  }

  Future<void> _onFetchCategories(
      FetchCategories event, Emitter<HomeState> emit) async {
    emit(state.copyWith(categoriesStatus: DataStatus.loading));
    final result = await getCategories(NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        categoriesStatus: DataStatus.error,
        categoriesError: failure.message,
      )),
      (data) => emit(state.copyWith(
        categoriesStatus: DataStatus.loaded,
        categories: data,
      )),
    );
  }

  Future<void> _onFetchTrendingItems(
      FetchTrendingItems event, Emitter<HomeState> emit) async {
    emit(state.copyWith(trendingStatus: DataStatus.loading));
    final result = await getTrendingItems(NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        trendingStatus: DataStatus.error,
        trendingError: failure.message,
      )),
      (data) => emit(state.copyWith(
        trendingStatus: DataStatus.loaded,
        trendingItems: data,
      )),
    );
  }

  Future<void> _onFetchPersonalizedItems(
      FetchPersonalizedItems event, Emitter<HomeState> emit) async {
    emit(state.copyWith(personalizedStatus: DataStatus.loading));
    final result = await getPersonalizedRecommendations(NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        personalizedStatus: DataStatus.error,
        personalizedError: failure.message,
      )),
      (data) => emit(state.copyWith(
        personalizedStatus: DataStatus.loaded,
        personalizedItems: data,
      )),
    );
  }
}
