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
    int page = 1,
    int limit = 10,
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
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // Membuat semua pengecekan parameter konsisten dan robust
      final Map<String, dynamic> queryParams = {
        'type': type,
        'page': page,
        'limit': limit,
      };
      if (query != null && query.isNotEmpty) queryParams['q'] = query;
      if (categoryId != null && categoryId.isNotEmpty) {
        queryParams['category_id'] = categoryId;
      }
      if (size != null && size.isNotEmpty) queryParams['size'] = size;
      if (color != null && color.isNotEmpty) queryParams['color'] = color;
      if (condition != null && condition.isNotEmpty) {
        queryParams['condition'] = condition;
      }
      if (sortBy != null && sortBy.isNotEmpty) queryParams['sort_by'] = sortBy;
      if (sortOrder != null && sortOrder.isNotEmpty) {
        queryParams['sort_order'] = sortOrder;
      }
      if (city != null && city.isNotEmpty) queryParams['city'] = city;
      if (minPrice != null) queryParams['min_price'] = minPrice;
      if (maxPrice != null) queryParams['max_price'] = maxPrice;

      final response = await dio.get(
        AppUrls.items,
        queryParameters: queryParams,
      );

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
      final message = e.response?.data?['error']?['message'] ??
          e.response?.data?['message'] ??
          'Gagal mencari item';
      throw ServerException(message: message);
    } catch (e) {
      throw ServerException(
          message: 'Terjadi kesalahan tidak terduga: ${e.toString()}');
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
