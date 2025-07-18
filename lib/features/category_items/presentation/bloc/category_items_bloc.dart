import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/features/category_items/domain/entities/item_entity.dart';
import 'package:satulemari/features/category_items/domain/usecases/get_items_by_category_usecase.dart';

part 'category_items_event.dart';
part 'category_items_state.dart';

class CategoryItemsBloc extends Bloc<CategoryItemsEvent, CategoryItemsState> {
  final GetItemsByCategoryUseCase getItemsByCategory;

  CategoryItemsBloc({required this.getItemsByCategory})
      : super(CategoryItemsInitial()) {
    on<FetchCategoryItems>((event, emit) async {
      emit(CategoryItemsLoading());
      final result = await getItemsByCategory(
          GetItemsByCategoryParams(categoryId: event.categoryId));
      result.fold(
        (failure) => emit(CategoryItemsError(failure.message)),
        (items) => emit(CategoryItemsLoaded(items)),
      );
    });
  }
}
