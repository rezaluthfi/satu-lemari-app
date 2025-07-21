import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/features/category_items/domain/entities/item_entity.dart';
import 'package:satulemari/features/item_detail/domain/entities/item_detail.dart';

abstract class ItemDetailRepository {
  Future<Either<Failure, ItemDetail>> getItemById(String id);
  Future<Either<Failure, List<Item>>> getItemsByIds(List<String> ids);
}
