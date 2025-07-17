import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/exceptions.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/network/network_info.dart';
import 'package:satulemari/features/home/data/datasources/home_remote_datasource.dart';
import 'package:satulemari/features/home/data/models/recommendation_model.dart';
import 'package:satulemari/features/home/domain/entities/category.dart';
import 'package:satulemari/features/home/domain/entities/recommendation.dart';
import 'package:satulemari/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  // Helper function untuk mapping yang lebih defensif
  Recommendation _mapModelToEntity(RecommendationModel model) {
    ItemType type = ItemType.unknown;
    if (model.data.tags.any((tag) => tag.toLowerCase() == 'donation')) {
      type = ItemType.donation;
    } else if (model.data.tags.any((tag) => tag.toLowerCase() == 'rental')) {
      type = ItemType.rental;
    }

    // Jika data.name tidak ada, gunakan title dari level atas
    final title = model.data.name ?? model.title;

    final categoryName = model.data.category;
    // Cek jika categoryName adalah UUID atau null
    final bool isInvalidCategory = categoryName == null ||
        (categoryName.length > 20 && categoryName.contains('-'));

    return Recommendation(
      itemId: model.data.itemId ?? '', // Beri default string kosong jika null
      title: title,
      description: model.description,
      imageUrl: model.data.images.isNotEmpty ? model.data.images.first : null,
      category: isInvalidCategory ? 'Umum' : categoryName,
      type: type,
      tags: model.data.tags,
    );
  }

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteModels = await remoteDataSource.getCategories();
        final entities = remoteModels
            .map((model) =>
                Category(id: model.id, name: model.name, icon: model.icon))
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
