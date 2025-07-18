import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/features/category_items/domain/entities/item_entity.dart';

abstract class CategoryItemsRepository {
  Future<Either<Failure, List<Item>>> getItemsByCategoryId(String categoryId);
}
