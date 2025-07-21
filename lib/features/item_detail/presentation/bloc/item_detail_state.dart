part of 'item_detail_bloc.dart';

enum ItemDetailButtonState {
  /// Tombol aktif dan bisa diklik
  active,

  /// Tombol non-aktif karena stok barang habis
  outOfStock,

  /// Tombol non-aktif karena user sudah punya permintaan untuk barang ini
  pendingRequest,

  /// Tombol non-aktif karena kuota donasi mingguan user sudah habis
  quotaExceeded,
}

abstract class ItemDetailState extends Equatable {
  const ItemDetailState();
  @override
  List<Object> get props => [];
}

class ItemDetailInitial extends ItemDetailState {}

class ItemDetailLoading extends ItemDetailState {}

class ItemDetailLoaded extends ItemDetailState {
  final ItemDetail item;

  final ItemDetailButtonState buttonState;

  const ItemDetailLoaded(this.item, {required this.buttonState});

  @override
  List<Object> get props => [item, buttonState];
}

class ItemDetailError extends ItemDetailState {
  final String message;
  const ItemDetailError(this.message);
  @override
  List<Object> get props => [message];
}
