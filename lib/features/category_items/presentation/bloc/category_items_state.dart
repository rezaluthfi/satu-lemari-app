part of 'category_items_bloc.dart';

abstract class CategoryItemsState extends Equatable {
  const CategoryItemsState();
  @override
  List<Object> get props => [];
}

class CategoryItemsInitial extends CategoryItemsState {}

class CategoryItemsLoading extends CategoryItemsState {}

class CategoryItemsLoaded extends CategoryItemsState {
  final List<Item> items;
  const CategoryItemsLoaded(this.items);
  @override
  List<Object> get props => [items];
}

class CategoryItemsError extends CategoryItemsState {
  final String message;
  const CategoryItemsError(this.message);
  @override
  List<Object> get props => [message];
}
