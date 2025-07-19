part of 'browse_bloc.dart';

abstract class BrowseEvent extends Equatable {
  const BrowseEvent();
  @override
  List<Object?> get props => [];
}

// Dipanggil saat pertama kali atau saat pull-to-refresh
class BrowseDataFetched extends BrowseEvent {}

// Dipanggil saat tab diganti
class TabChanged extends BrowseEvent {
  final int index; // 0 for donation, 1 for rental
  const TabChanged(this.index);
  @override
  List<Object> get props => [index];
}

// Dipanggil saat teks pencarian berubah (akan di-debounce)
class SearchTermChanged extends BrowseEvent {
  final String query;
  const SearchTermChanged(this.query);
  @override
  List<Object> get props => [query];
}

// Event yang dieksekusi secara instan saat tombol clear ditekan
class SearchCleared extends BrowseEvent {}

// Dipanggil saat filter diterapkan
class FilterApplied extends BrowseEvent {
  final String? categoryId;
  final String? size;
  const FilterApplied({this.categoryId, this.size});
  @override
  List<Object?> get props => [categoryId, size];
}

// Event untuk mereset semua filter
class ResetFilters extends BrowseEvent {
  @override
  List<Object?> get props => [];
}
