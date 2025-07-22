// lib/features/browse/presentation/bloc/browse_event.dart
part of 'browse_bloc.dart';

abstract class BrowseEvent extends Equatable {
  const BrowseEvent();
  @override
  List<Object?> get props => [];
}

class SuggestionsRequested extends BrowseEvent {
  final String query;
  const SuggestionsRequested(this.query);

  @override
  List<Object> get props => [query];
}

class BrowseDataFetched extends BrowseEvent {}

class TabChanged extends BrowseEvent {
  final int index;
  const TabChanged(this.index);
  @override
  List<Object> get props => [index];
}

class SearchTermChanged extends BrowseEvent {
  final String query;
  const SearchTermChanged(this.query);
  @override
  List<Object> get props => [query];
}

class SearchCleared extends BrowseEvent {}

class FilterApplied extends BrowseEvent {
  final String? categoryId;
  final String? size;
  final String? sortBy;
  final String? sortOrder;
  final String? city;
  final double? minPrice;
  final double? maxPrice;

  const FilterApplied({
    this.categoryId,
    this.size,
    this.sortBy,
    this.sortOrder,
    this.city,
    this.minPrice,
    this.maxPrice,
  });

  @override
  List<Object?> get props =>
      [categoryId, size, sortBy, sortOrder, city, minPrice, maxPrice];
}

class ResetFilters extends BrowseEvent {}

class IntentAnalysisAndSearchRequested extends BrowseEvent {
  final String query;
  const IntentAnalysisAndSearchRequested(this.query);

  @override
  List<Object> get props => [query];
}
