import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/browse/domain/repositories/browse_repository.dart';
import 'package:satulemari/features/category_items/domain/entities/item_entity.dart';

class GetSimilarItemsUseCase
    implements UseCase<List<Item>, GetSimilarItemsParams> {
  final BrowseRepository repository;
  GetSimilarItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Item>>> call(GetSimilarItemsParams params) async {
    return await repository.getSimilarItems(params.itemId);
  }
}

class GetSimilarItemsParams extends Equatable {
  final String itemId;

  const GetSimilarItemsParams({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}
