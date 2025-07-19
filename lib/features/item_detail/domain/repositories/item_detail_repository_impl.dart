import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/exceptions.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/network/network_info.dart';
import 'package:satulemari/features/item_detail/data/datasources/item_detail_remote_datasource.dart';
import 'package:satulemari/features/item_detail/domain/entities/item_detail.dart';
import 'package:satulemari/features/item_detail/domain/repositories/item_detail_repository.dart';

class ItemDetailRepositoryImpl implements ItemDetailRepository {
  final ItemDetailRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ItemDetailRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ItemDetail>> getItemById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final model = await remoteDataSource.getItemById(id);
        final entity = ItemDetail(
          id: model.id,
          name: model.name,
          description: model.description,
          size: model.size,
          color: model.color,
          type: model.type,
          availableQuantity: model.availableQuantity,
          condition: model.condition,
          images: model.images,
          // --- PERBAIKI MAPPING PARTNER DI SINI ---
          partner: Partner(
            id: model.partner.id,
            username: model.partner.username,
            fullName: model.partner.fullName,
            photo: model.partner.photo,
            phone: model.partner.phone,
            address: model.partner.address,
            latitude: model.partner.latitude,
            longitude: model.partner.longitude,
          ),
          // ---
          category: CategoryInfo(
            id: model.category.id,
            name: model.category.name,
          ),
        );
        return Right(entity);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('No Internet Connection'));
    }
  }
}
