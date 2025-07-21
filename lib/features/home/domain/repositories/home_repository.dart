import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/features/home/domain/entities/category.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<Category>>> getCategories();
  Future<Either<Failure, List<String>>> getTrendingItemIds();
  Future<Either<Failure, List<String>>> getPersonalizedRecommendationIds();
}
