import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/features/home/domain/entities/category.dart';
import 'package:satulemari/features/home/domain/entities/recommendation.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<Category>>> getCategories();
  Future<Either<Failure, List<Recommendation>>> getTrendingItems();
  Future<Either<Failure, List<Recommendation>>>
      getPersonalizedRecommendations();
}
