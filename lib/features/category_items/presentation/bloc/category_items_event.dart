part of 'category_items_bloc.dart';

abstract class CategoryItemsEvent extends Equatable {
  const CategoryItemsEvent();
  @override
  List<Object> get props => [];
}

class FetchCategoryItems extends CategoryItemsEvent {
  final String categoryId;
  const FetchCategoryItems(this.categoryId);
  @override
  List<Object> get props => [categoryId];
}
