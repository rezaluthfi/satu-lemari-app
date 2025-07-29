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

enum SimilarItemsStatus { initial, loading, loaded, error }

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

  final SimilarItemsStatus similarItemsStatus;
  final List<Item> similarItems;
  final String? similarItemsError;

  const ItemDetailLoaded(
    this.item, {
    required this.buttonState,
    this.similarItemsStatus = SimilarItemsStatus.initial,
    this.similarItems = const [],
    this.similarItemsError,
  });

  // --- TAMBAHKAN METHOD COPYWITH ---
  ItemDetailLoaded copyWith({
    ItemDetail? item,
    ItemDetailButtonState? buttonState,
    SimilarItemsStatus? similarItemsStatus,
    List<Item>? similarItems,
    String? similarItemsError,
  }) {
    return ItemDetailLoaded(
      item ?? this.item,
      buttonState: buttonState ?? this.buttonState,
      similarItemsStatus: similarItemsStatus ?? this.similarItemsStatus,
      similarItems: similarItems ?? this.similarItems,
      similarItemsError: similarItemsError ?? this.similarItemsError,
    );
  }
  // --- AKHIR TAMBAHAN ---

  @override
  List<Object> get props => [
        item,
        buttonState,
        similarItemsStatus,
        similarItems,
        similarItemsError ?? ''
      ];
}

class ItemDetailError extends ItemDetailState {
  final String message;
  const ItemDetailError(this.message);
  @override
  List<Object> get props => [message];
}
