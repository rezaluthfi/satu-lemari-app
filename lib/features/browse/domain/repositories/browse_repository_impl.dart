// lib/features/browse/data/repositories/browse_repository_impl.dart

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

class BrowseRepositoryImpl implements BrowseRepository {
  final BrowseRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final CategoryCacheService categoryCache;

  BrowseRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.categoryCache,
  });

  Item _mapItemModelToItemEntity(ItemModel model) {
    ItemType type = ItemType.unknown;
    if (model.type?.toLowerCase() == 'donation') {
      type = ItemType.donation;
    } else if (model.type?.toLowerCase() == 'rental') {
      type = ItemType.rental;
    }

    final categoryName = model.categoryId != null
        ? categoryCache.getCategoryNameById(model.categoryId!)
        : null;

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
      categoryName: categoryName,
    );
  }

  @override
  Future<Either<Failure, List<Item>>> searchItems(
      SearchItemsParams params) async {
    if (await networkInfo.isConnected) {
      try {
        // Teruskan semua parameter baru ke remoteDataSource
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

        // Mapping dari Model ke Entity, sekarang sertakan semua filter dari AI
        final entity = IntentAnalysis(
          query: data.query,
          filters: IntentFilters(
            search: data.filters.search,
            size: data.filters.size,
            color: data.filters.color, // Ambil color dari AI
            condition: data.filters.condition, // Ambil condition dari AI
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
}
