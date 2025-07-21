import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/exceptions.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/network/network_info.dart';
import 'package:satulemari/features/category_items/domain/entities/item_entity.dart';
import 'package:satulemari/features/home/domain/entities/recommendation.dart'; // Mengambil ItemType
import 'package:satulemari/features/item_detail/data/datasources/item_detail_remote_datasource.dart';
import 'package:satulemari/features/item_detail/data/models/item_detail_model.dart';
import 'package:satulemari/features/item_detail/domain/entities/item_detail.dart';
import 'package:satulemari/features/item_detail/domain/repositories/item_detail_repository.dart';

class ItemDetailRepositoryImpl implements ItemDetailRepository {
  final ItemDetailRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ItemDetailRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  Item _mapItemDetailModelToItem(ItemDetailModel model) {
    ItemType type = ItemType.unknown;
    if (model.type?.toLowerCase() == 'donation') {
      type = ItemType.donation;
    } else if (model.type?.toLowerCase() == 'rental') {
      type = ItemType.rental;
    }

    return Item(
      id: model.id,
      name: model.name ?? 'Nama Tidak Tersedia', // Fallback
      imageUrl: model.images.isNotEmpty ? model.images.first : null,
      type: type,
      size: model.size,
      condition: model.condition,
      price: model.price,
      categoryName: model.category?.name ?? 'Lainnya', // Fallback
      availableQuantity: model.availableQuantity,
    );
  }

  @override
  Future<Either<Failure, ItemDetail>> getItemById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final model = await remoteDataSource.getItemById(id);

        // Validasi data penting sebelum mapping
        if (model.name == null ||
            model.type == null ||
            model.condition == null ||
            model.partner == null ||
            model.category == null) {
          return Left(ServerFailure('Data item tidak lengkap dari server.'));
        }

        final entity = ItemDetail(
          id: model.id,
          name: model.name!,
          description: model.description ?? 'Tidak ada deskripsi.',
          size: model.size,
          color: model.color,
          type: model.type!,
          availableQuantity: model.availableQuantity ?? 0,
          condition: model.condition!,
          images: model.images,
          partner: Partner(
            id: model.partner!.id,
            username: model.partner!.username,
            fullName: model.partner!.fullName,
            photo: model.partner!.photo,
            phone: model.partner!.phone,
            address: model.partner!.address,
            latitude: model.partner!.latitude,
            longitude: model.partner!.longitude,
          ),
          category: CategoryInfo(
            id: model.category!.id,
            name: model.category!.name,
          ),
          // ===============================================
          //           PERUBAHAN UTAMA DI SINI
          // ===============================================
          price: model.price, // <-- Tambahkan baris ini
        );
        return Right(entity);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failure, List<Item>>> getItemsByIds(List<String> ids) async {
    if (await networkInfo.isConnected) {
      try {
        final models = await remoteDataSource.getItemsByIds(ids);
        final entities = models.map(_mapItemDetailModelToItem).toList();
        return Right(entities);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('No Internet Connection'));
    }
  }
}
