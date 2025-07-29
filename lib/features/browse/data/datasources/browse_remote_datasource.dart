// lib/features/browse/data/datasources/browse_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:satulemari/core/constants/app_urls.dart';
import 'package:satulemari/core/errors/exceptions.dart';
import 'package:satulemari/features/browse/data/models/ai_suggestions_model.dart';
import 'package:satulemari/features/browse/data/models/intent_analysis_model.dart';
import 'package:satulemari/features/browse/data/models/similar_items_model.dart';
import 'package:satulemari/features/category_items/data/models/item_model.dart';

abstract class BrowseRemoteDataSource {
  Future<List<ItemModel>> searchItems({
    required String type,
    String? query,
    String? categoryId,
    String? size,
    String? color,
    String? condition,
    String? sortBy,
    String? sortOrder,
    String? city,
    double? minPrice,
    double? maxPrice,
  });

  Future<AiSuggestionsModel> getAiSuggestions(String query);

  Future<IntentAnalysisResponseModel> analyzeIntent(String query);

  Future<SimilarItemsResponseModel> getSimilarItems(String itemId);
}

class BrowseRemoteDataSourceImpl implements BrowseRemoteDataSource {
  final Dio dio;
  BrowseRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ItemModel>> searchItems({
    required String type,
    String? query,
    String? categoryId,
    String? size,
    String? color,
    String? condition,
    String? sortBy,
    String? sortOrder,
    String? city,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'type': type,
        if (query != null && query.isNotEmpty) 'q': query,
        if (categoryId != null) 'category_id': categoryId,
        if (size != null) 'size': size,
        if (color != null) 'color': color,
        if (condition != null) 'condition': condition,
        if (sortBy != null) 'sort_by': sortBy,
        if (sortOrder != null) 'sort_order': sortOrder,
        if (city != null && city.isNotEmpty) 'city': city,
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
      };

      final response = await dio.get(
        AppUrls.items,
        queryParameters: queryParams,
      );

      // Untuk menangani payload yang mungkin berbeda
      final dynamic responseData = response.data['data'];
      final List<dynamic> itemList = responseData is List
          ? responseData
          : (responseData is Map &&
                  responseData.containsKey('items') &&
                  responseData['items'] is List)
              ? responseData['items']
              : [];

      return itemList.map((json) => ItemModel.fromJson(json)).toList();
    } on DioException catch (e) {
      // Lebih baik menangkap pesan error spesifik dari backend jika ada
      final message = e.response?.data?['error']?['message'] ??
          e.response?.data?['message'] ??
          'Gagal mencari item';
      throw ServerException(message: message);
    } catch (e) {
      // Menangkap error lainnya (misal: parsing)
      throw ServerException(message: 'Terjadi kesalahan tidak terduga');
    }
  }

  @override
  Future<AiSuggestionsModel> getAiSuggestions(String query) async {
    try {
      final response = await dio.get(
        AppUrls.aiSuggestions,
        queryParameters: {'q': query},
      );
      return AiSuggestionsModel.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Gagal memuat saran';
      throw ServerException(message: message);
    }
  }

  @override
  Future<IntentAnalysisResponseModel> analyzeIntent(String query) async {
    try {
      final response = await dio.post(
        AppUrls.aiIntent,
        data: {'query': query},
      );
      return IntentAnalysisResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Gagal menganalisis permintaan';
      throw ServerException(message: message);
    }
  }

  @override
  Future<SimilarItemsResponseModel> getSimilarItems(String itemId) async {
    try {
      final response = await dio.get(
        '${AppUrls.aiSimilarItems}/$itemId',
      );
      return SimilarItemsResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Gagal memuat item serupa';
      throw ServerException(message: message);
    } catch (e) {
      throw ServerException(message: 'Terjadi kesalahan tidak terduga');
    }
  }
}
