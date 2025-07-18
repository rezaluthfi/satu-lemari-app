import 'package:dio/dio.dart';
import 'package:satulemari/core/constants/app_urls.dart';
import 'package:satulemari/core/errors/exceptions.dart';
import 'package:satulemari/features/category_items/data/models/item_model.dart';

abstract class CategoryItemsRemoteDataSource {
  Future<List<ItemModel>> getItemsByCategoryId(String categoryId);
}

class CategoryItemsRemoteDataSourceImpl
    implements CategoryItemsRemoteDataSource {
  final Dio dio;

  CategoryItemsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ItemModel>> getItemsByCategoryId(String categoryId) async {
    try {
      final response = await dio.get(
        AppUrls.items,
        queryParameters: {'category_id': categoryId},
      );
      final List<dynamic> data = response.data['data'];
      // Use the ItemModel.fromJson factory to convert each item
      return data.map((json) => ItemModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to load items';
      throw ServerException(message: message);
    } catch (e) {
      throw ServerException(message: 'Gagal memproses data: ${e.toString()}');
    }
  }
}
