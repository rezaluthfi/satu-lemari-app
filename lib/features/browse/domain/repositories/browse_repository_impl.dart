import 'package:dartz/dartz.dart';
import 'package:satulemari/core/services/category_cache_service.dart';
import 'package:satulemari/features/browse/data/datasources/browse_remote_datasource.dart';
import 'package:satulemari/features/browse/domain/entities/ai_suggestions.dart';
import 'package:satulemari/features/browse/domain/entities/intent_analysis.dart';
import 'package:satulemari/features/browse/domain/repositories/browse_repository.dart';
import 'package:satulemari/core/errors/exceptions.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/network/network_info.dart';
import 'package:satulemari/features/browse/domain/usecases/search_items_usecase.dart';
import 'package:satulemari/features/category_items/data/models/item_model.dart';
import 'package:satulemari/features/category_items/domain/entities/item_entity.dart';
import 'package:satulemari/features/home/domain/entities/recommendation.dart';
import 'package:satulemari/features/item_detail/data/datasources/item_detail_remote_datasource.dart';
import 'package:satulemari/features/item_detail/data/models/item_detail_model.dart';

class BrowseRepositoryImpl implements BrowseRepository {
  final BrowseRemoteDataSource remoteDataSource;
  final ItemDetailRemoteDataSource itemDetailRemoteDataSource;
  final NetworkInfo networkInfo;
  final CategoryCacheService categoryCache;

  BrowseRepositoryImpl({
    required this.remoteDataSource,
    required this.itemDetailRemoteDataSource,
    required this.networkInfo,
    required this.categoryCache,
  });

  Item _mapItemModelToItemEntity(ItemModel model) {
    // Menggunakan categoryName dari model jika ada (hasil dari @JsonKey fromJson)
    // atau fallback ke cache jika tidak ada.
    final categoryName = model.categoryName ??
        (model.categoryId != null
            ? categoryCache.getCategoryNameById(model.categoryId!)
            : null);

    return Item(
      id: model.id,
      name: model.name ?? 'Tanpa Nama',
      description: model.description,
      imageUrl: model.images.isNotEmpty ? model.images.first : null,
      // Langsung gunakan nilai enum dari model. Tidak ada lagi konversi manual.
      type: model.type ?? ItemType.unknown,
      size: model.size,
      condition: model.condition,
      availableQuantity: model.availableQuantity,
      price: model.price,
      categoryName: categoryName,
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
          color: params.color,
          condition: params.condition,
          sortBy: params.sortBy,
          sortOrder: params.sortOrder,
          city: params.city,
          minPrice: params.minPrice,
          maxPrice: params.maxPrice,
          page: params.page,
          limit: params.limit,
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

  @override
  Future<Either<Failure, AiSuggestions>> getAiSuggestions(String query) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteModel = await remoteDataSource.getAiSuggestions(query);
        return Right(remoteModel);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failure, IntentAnalysis>> analyzeIntent(String query) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteModel = await remoteDataSource.analyzeIntent(query);
        final data = remoteModel.data;

        String? categoryId;
        if (data.entities.category != null &&
            data.entities.category!.isNotEmpty) {
          categoryId =
              categoryCache.getCategoryIdByName(data.entities.category!);
        }

        final entity = IntentAnalysis(
          originalQuery: data.query,
          filters: IntentFilters(
            search: data.filters.search,
            size: data.filters.size,
            color: data.filters.color,
            condition: data.filters.condition,
            maxPrice: data.filters.maxPrice,
            categoryId: categoryId,
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

  @override
  Future<Either<Failure, List<Item>>> getSimilarItems(String itemId) async {
    if (await networkInfo.isConnected) {
      try {
        final similarItemsResponse =
            await remoteDataSource.getSimilarItems(itemId);

        final List<String> similarItemIds = similarItemsResponse
            .data.similarItems
            .map((item) => item.data.itemId)
            .toList();

        if (similarItemIds.isEmpty) {
          return const Right([]);
        }

        final List<ItemDetailModel> detailedItemModels =
            await itemDetailRemoteDataSource.getItemsByIds(similarItemIds);

        final entities = detailedItemModels.map((detailModel) {
          ItemType type;
          switch (detailModel.type?.toLowerCase()) {
            case 'donation':
              type = ItemType.donation;
              break;
            case 'rental':
              type = ItemType.rental;
              break;
            case 'thrifting':
              type = ItemType.thrifting;
              break;
            default:
              type = ItemType.unknown;
          }

          return Item(
            id: detailModel.id,
            name: detailModel.name ?? 'Tanpa Nama',
            imageUrl:
                detailModel.images.isNotEmpty ? detailModel.images.first : null,
            type: type,
            size: detailModel.size,
            condition: detailModel.condition,
            availableQuantity: detailModel.availableQuantity,
            price: detailModel.price,
            categoryName: detailModel.category?.name,
          );
        }).toList();

        return Right(entities);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Gagal memproses barang serupa.'));
      }
    } else {
      return Left(ConnectionFailure('No Internet Connection'));
    }
  }
}
