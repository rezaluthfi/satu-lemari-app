import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/exceptions.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/network/network_info.dart';
import 'package:satulemari/features/home/data/datasources/home_remote_datasource.dart';
import 'package:satulemari/features/home/domain/entities/category.dart';
import 'package:satulemari/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

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
  Future<Either<Failure, List<String>>> getTrendingItemIds() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteModels = await remoteDataSource.getTrendingItems();
        final ids = remoteModels
            .map((model) => model.data.itemId)
            .where((id) => id != null && id.isNotEmpty)
            .cast<String>()
            .toList();
        return Right(ids);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failure, List<String>>>
      getPersonalizedRecommendationIds() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteModels =
            await remoteDataSource.getPersonalizedRecommendations();
        final ids = remoteModels
            .map((model) => model.data.itemId)
            .where((id) => id != null && id.isNotEmpty)
            .cast<String>()
            .toList();
        return Right(ids);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('No Internet Connection'));
    }
  }
}
