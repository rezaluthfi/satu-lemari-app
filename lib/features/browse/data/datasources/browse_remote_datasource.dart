import 'package:dio/dio.dart';
import 'package:satulemari/core/constants/app_urls.dart';
import 'package:satulemari/core/errors/exceptions.dart';
import 'package:satulemari/features/category_items/data/models/item_model.dart';

abstract class BrowseRemoteDataSource {
  Future<List<ItemModel>> searchItems({
    required String type,
    String? query,
    String? categoryId,
    String? size,
  });
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
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'type': type,
        if (query != null && query.isNotEmpty) 'q': query,
        if (categoryId != null) 'category_id': categoryId,
        if (size != null) 'size': size,
        // Tambahkan filter lain di sini jika perlu
      };

      // Menggunakan endpoint /items/search
      final response = await dio.get(
        AppUrls.searchItems,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data'];
      return data.map((json) => ItemModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Gagal mencari item';
      throw ServerException(message: message);
    }
  }
}
