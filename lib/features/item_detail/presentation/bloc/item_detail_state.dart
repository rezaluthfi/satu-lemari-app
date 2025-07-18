part of 'item_detail_bloc.dart';

abstract class ItemDetailState extends Equatable {
  const ItemDetailState();
  @override
  List<Object> get props => [];
}

class ItemDetailInitial extends ItemDetailState {}

class ItemDetailLoading extends ItemDetailState {}

class ItemDetailLoaded extends ItemDetailState {
  final ItemDetail item;
  const ItemDetailLoaded(this.item);
  @override
  List<Object> get props => [item];
}

class ItemDetailError extends ItemDetailState {
  final String message;
  const ItemDetailError(this.message);
  @override
  List<Object> get props => [message];
}
