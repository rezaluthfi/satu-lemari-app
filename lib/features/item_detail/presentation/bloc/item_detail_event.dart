part of 'item_detail_bloc.dart';

abstract class ItemDetailEvent extends Equatable {
  const ItemDetailEvent();
  @override
  List<Object> get props => [];
}

class FetchItemDetail extends ItemDetailEvent {
  final String id;
  const FetchItemDetail(this.id);
  @override
  List<Object> get props => [id];
}

class FetchSimilarItems extends ItemDetailEvent {
  final String itemId;
  const FetchSimilarItems(this.itemId);
  @override
  List<Object> get props => [itemId];
}
