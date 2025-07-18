import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/exceptions.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/network/network_info.dart';
import 'package:satulemari/features/category_items/data/datasources/category_items_remote_datasource.dart';
import 'package:satulemari/features/category_items/domain/repositories/category_items_repository.dart';
import 'package:satulemari/features/category_items/data/models/item_model.dart';
import 'package:satulemari/features/category_items/domain/entities/item_entity.dart';
import 'package:satulemari/features/home/domain/entities/recommendation.dart';

class CategoryItemsRepositoryImpl implements CategoryItemsRepository {
  final CategoryItemsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  CategoryItemsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  Item _mapItemModelToItemEntity(ItemModel model) {
    ItemType type = ItemType.unknown;
    if (model.type?.toLowerCase() == 'donation') {
      type = ItemType.donation;
    } else if (model.type?.toLowerCase() == 'rental') {
      type = ItemType.rental;
    }

    return Item(
      id: model.id,
      name: model.name ?? 'Tanpa Nama',
      description: model.description,
      imageUrl: model.images.isNotEmpty ? model.images.first : null,
      type: type,
      size: model.size,
      condition: model.condition,
      availableQuantity: model.availableQuantity,
      price: model.price,
    );
  }

  @override
  Future<Either<Failure, List<Item>>> getItemsByCategoryId(
      String categoryId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteModels =
            await remoteDataSource.getItemsByCategoryId(categoryId);
        final entities = remoteModels.map(_mapItemModelToItemEntity).toList();
        return Right(entities);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('No Internet Connection'));
    }
  }
}
