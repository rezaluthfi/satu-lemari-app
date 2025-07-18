import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/item_detail/domain/entities/item_detail.dart';
import 'package:satulemari/features/item_detail/domain/repositories/item_detail_repository.dart';

class GetItemByIdUseCase implements UseCase<ItemDetail, GetItemByIdParams> {
  final ItemDetailRepository repository;

  GetItemByIdUseCase(this.repository);

  @override
  Future<Either<Failure, ItemDetail>> call(GetItemByIdParams params) async {
    return await repository.getItemById(params.id);
  }
}

class GetItemByIdParams extends Equatable {
  final String id;

  const GetItemByIdParams({required this.id});

  @override
  List<Object> get props => [id];
}
