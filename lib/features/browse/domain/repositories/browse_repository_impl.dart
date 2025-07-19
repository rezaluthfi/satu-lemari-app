import 'package:dartz/dartz.dart';
import 'package:satulemari/features/browse/data/datasources/browse_remote_datasource.dart';
import 'package:satulemari/features/browse/domain/repositories/browse_repository.dart';
import 'package:satulemari/core/errors/exceptions.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/network/network_info.dart';
import 'package:satulemari/features/browse/domain/usecases/search_items_usecase.dart';
import 'package:satulemari/features/category_items/data/models/item_model.dart';
import 'package:satulemari/features/category_items/domain/entities/item_entity.dart';
import 'package:satulemari/features/home/domain/entities/recommendation.dart';

class BrowseRepositoryImpl implements BrowseRepository {
  final BrowseRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  BrowseRepositoryImpl(
      {required this.remoteDataSource, required this.networkInfo});

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
  Future<Either<Failure, List<Item>>> searchItems(
      SearchItemsParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteModels = await remoteDataSource.searchItems(
          type: params.type,
          query: params.query,
          categoryId: params.categoryId,
          size: params.size,
        );
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
