import 'package:dio/dio.dart';
import 'package:satulemari/core/constants/app_urls.dart';
import 'package:satulemari/core/errors/exceptions.dart';
import 'package:satulemari/features/home/data/models/category_model.dart';
import 'package:satulemari/features/home/data/models/recommendation_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<List<RecommendationModel>> getTrendingItems();
  Future<List<RecommendationModel>> getPersonalizedRecommendations();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;

  HomeRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await dio.get(AppUrls.categories);
      final List<dynamic> data = response.data['data'];
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        throw ServerException(
            message: 'Server terlalu lama merespons. Silakan coba lagi.');
      }
      final message =
          e.response?.data['message'] ?? 'Failed to load categories';
      throw ServerException(message: message);
    }
  }

  @override
  Future<List<RecommendationModel>> getTrendingItems() async {
    try {
      final response = await dio.get(AppUrls.trendingRecommendations);
      final List<dynamic> data = response.data['data']['trending_items'];
      return data.map((json) => RecommendationModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        throw ServerException(
            message: 'Server terlalu lama merespons. Silakan coba lagi.');
      }
      final message =
          e.response?.data['message'] ?? 'Failed to load trending items';
      throw ServerException(message: message);
    }
  }

  @override
  Future<List<RecommendationModel>> getPersonalizedRecommendations() async {
    try {
      final response = await dio.get(
        AppUrls.personalizedRecommendations,
        queryParameters: {'context': 'browse', 'limit': 10},
      );
      final List<dynamic> data = response.data['data']['recommendations'];
      return data.map((json) => RecommendationModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        throw ServerException(
            message: 'Server terlalu lama merespons. Silakan coba lagi.');
      }
      final message =
          e.response?.data['message'] ?? 'Failed to load recommendations';
      throw ServerException(message: message);
    }
  }
}
