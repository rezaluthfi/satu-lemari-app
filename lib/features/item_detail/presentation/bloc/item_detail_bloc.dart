import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/features/item_detail/domain/entities/item_detail.dart';
import 'package:satulemari/features/item_detail/domain/usecases/get_item_by_id_usecase.dart';

part 'item_detail_event.dart';
part 'item_detail_state.dart';

class ItemDetailBloc extends Bloc<ItemDetailEvent, ItemDetailState> {
  final GetItemByIdUseCase getItemById;

  ItemDetailBloc({required this.getItemById}) : super(ItemDetailInitial()) {
    on<FetchItemDetail>((event, emit) async {
      emit(ItemDetailLoading());
      final result = await getItemById(GetItemByIdParams(id: event.id));
      result.fold(
        (failure) => emit(ItemDetailError(failure.message)),
        (item) => emit(ItemDetailLoaded(item)),
      );
    });
  }
}
