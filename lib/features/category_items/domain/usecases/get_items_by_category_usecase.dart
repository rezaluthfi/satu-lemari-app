import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/category_items/domain/entities/item_entity.dart';
import 'package:satulemari/features/category_items/domain/repositories/category_items_repository.dart';

class GetItemsByCategoryUseCase
    implements UseCase<List<Item>, GetItemsByCategoryParams> {
  final CategoryItemsRepository repository;

  GetItemsByCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<Item>>> call(
      GetItemsByCategoryParams params) async {
    return await repository.getItemsByCategoryId(params.categoryId);
  }
}

class GetItemsByCategoryParams extends Equatable {
  final String categoryId;

  const GetItemsByCategoryParams({required this.categoryId});

  @override
  List<Object> get props => [categoryId];
}
