// lib/features/item_detail/domain/usecases/get_items_by_ids_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/category_items/domain/entities/item_entity.dart';
import 'package:satulemari/features/item_detail/domain/repositories/item_detail_repository.dart';

class GetItemsByIdsUseCase implements UseCase<List<Item>, GetItemsByIdsParams> {
  final ItemDetailRepository repository;
  GetItemsByIdsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Item>>> call(GetItemsByIdsParams params) async {
    // Jika daftar ID kosong, kembalikan daftar kosong untuk menghindari panggilan API yang tidak perlu
    if (params.ids.isEmpty) {
      return const Right([]);
    }
    return await repository.getItemsByIds(params.ids);
  }
}

class GetItemsByIdsParams extends Equatable {
  final List<String> ids;
  const GetItemsByIdsParams({required this.ids});
  @override
  List<Object> get props => [ids];
}
