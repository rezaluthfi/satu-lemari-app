import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/exceptions.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/network/network_info.dart';
import 'package:satulemari/features/home/data/datasources/home_remote_datasource.dart';
import 'package:satulemari/features/home/data/models/recommendation_model.dart';
import 'package:satulemari/features/home/domain/entities/category.dart'
    as home_entities;
import 'package:satulemari/features/home/domain/entities/recommendation.dart';
import 'package:satulemari/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  Recommendation _mapModelToEntity(RecommendationModel model) {
    ItemType type = ItemType.unknown;

    if (model.data.tags.any((tag) => tag.toLowerCase().trim() == 'donation')) {
      type = ItemType.donation;
    } else if (model.data.tags
        .any((tag) => tag.toLowerCase().trim() == 'rental')) {
      type = ItemType.rental;
    }

    final title = model.data.name ?? model.title;
    final categoryName = model.data.category;
    final bool isInvalidCategory = categoryName == null ||
        (categoryName.length > 20 && categoryName.contains('-'));

    return Recommendation(
      itemId: model.data.itemId ?? '',
      title: title,
      description: model.description,
      imageUrl: model.data.images.isNotEmpty ? model.data.images.first : null,
      category: isInvalidCategory ? 'Umum' : categoryName,
      type: type,
      tags: model.data.tags,
      size: model.data.size,
      condition: model.data.condition,
      price: model.data.price,
    );
  }

  @override
  Future<Either<Failure, List<home_entities.Category>>> getCategories() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteModels = await remoteDataSource.getCategories();

        final entities = remoteModels
            .map<home_entities.Category>((model) => home_entities.Category(
                id: model.id, name: model.name, icon: model.icon))
            .toList();

        return Right(entities);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failure, List<Recommendation>>> getTrendingItems() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteModels = await remoteDataSource.getTrendingItems();
        final entities = remoteModels.map(_mapModelToEntity).toList();
        return Right(entities);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failure, List<Recommendation>>>
      getPersonalizedRecommendations() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteModels =
            await remoteDataSource.getPersonalizedRecommendations();
        final entities = remoteModels.map(_mapModelToEntity).toList();
        return Right(entities);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('No Internet Connection'));
    }
  }
}
