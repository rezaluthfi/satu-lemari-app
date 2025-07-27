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

  List<RecommendationModel> _parseRecommendations(Response response) {
    // Pastikan response.data dan response.data['data'] tidak null dan merupakan Map
    if (response.data == null || response.data['data'] is! Map) {
      // Kembalikan list kosong jika struktur data tidak sesuai harapan
      return [];
    }

    final Map<String, dynamic> dataMap = response.data['data'];

    // Cek apakah ada kunci 'recommendations' atau 'trending_items'
    final List<dynamic>? recommendationsList =
        dataMap['recommendations'] ?? dataMap['trending_items'];

    if (recommendationsList == null) {
      // Kembalikan list kosong jika daftar tidak ditemukan atau bukan list
      return [];
    }

    return recommendationsList
        .map((json) => RecommendationModel.fromJson(json))
        .toList();
  }

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
      final message = e.response?.data['message'] ?? 'Gagal memuat kategori';
      throw ServerException(message: message);
    }
  }

  @override
  Future<List<RecommendationModel>> getTrendingItems() async {
    try {
      final response = await dio.get(AppUrls.trendingRecommendations);

      return _parseRecommendations(response);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        throw ServerException(
            message: 'Server terlalu lama merespons. Silakan coba lagi.');
      }
      final message = e.response?.data['message'] ?? 'Gagal memuat item tren';
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

      return _parseRecommendations(response);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        throw ServerException(
            message: 'Server terlalu lama merespons. Silakan coba lagi.');
      }
      final message = e.response?.data['message'] ?? 'Gagal memuat rekomendasi';
      throw ServerException(message: message);
    }
  }
}
