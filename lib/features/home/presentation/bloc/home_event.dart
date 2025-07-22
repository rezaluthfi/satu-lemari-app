part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object> get props => [];
}

class FetchAllHomeData extends HomeEvent {}

class FetchCategories extends HomeEvent {}

class FetchTrendingItems extends HomeEvent {}

class FetchPersonalizedItems extends HomeEvent {}

// --- TAMBAHKAN KELAS INI ---
class HomeReset extends HomeEvent {}
