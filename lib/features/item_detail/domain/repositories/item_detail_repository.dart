import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/features/item_detail/domain/entities/item_detail.dart';

abstract class ItemDetailRepository {
  Future<Either<Failure, ItemDetail>> getItemById(String id);
}
