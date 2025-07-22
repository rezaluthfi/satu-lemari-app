import 'package:dio/dio.dart';
import 'package:satulemari/core/constants/app_urls.dart';
import 'package:satulemari/core/errors/exceptions.dart';
import 'package:satulemari/features/browse/data/models/ai_suggestions_model.dart';
import 'package:satulemari/features/category_items/data/models/item_model.dart';

abstract class BrowseRemoteDataSource {
  Future<List<ItemModel>> searchItems({
    required String type,
    String? query,
    String? categoryId,
    String? size,
    String? sortBy,
    String? sortOrder,
    String? city,
    double? minPrice,
    double? maxPrice,
  });

  Future<AiSuggestionsModel> getAiSuggestions(String query);
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

      final List<dynamic> data = response.data['data'] is List
          ? response.data['data']
          : response.data['data']['items'];
      return data.map((json) => ItemModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Gagal mencari item';
      throw ServerException(message: message);
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
      final message = e.response?.data['message'] ?? 'Gagal memuat saran';
      throw ServerException(message: message);
    }
  }
}
