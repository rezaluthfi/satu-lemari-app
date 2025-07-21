import 'package:dio/dio.dart';
import 'package:satulemari/core/constants/app_urls.dart';
import 'package:satulemari/core/errors/exceptions.dart';
import 'package:satulemari/features/item_detail/data/models/item_detail_model.dart';

abstract class ItemDetailRemoteDataSource {
  Future<ItemDetailModel> getItemById(String id);
  Future<List<ItemDetailModel>> getItemsByIds(List<String> ids);
}

class ItemDetailRemoteDataSourceImpl implements ItemDetailRemoteDataSource {
  final Dio dio;

  ItemDetailRemoteDataSourceImpl({required this.dio});

  @override
  Future<ItemDetailModel> getItemById(String id) async {
    try {
      final response = await dio.get('${AppUrls.items}/$id');
      return ItemDetailModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ??
          'Failed to load item detail for id: $id';
      throw ServerException(message: message);
    }
  }

  @override
  Future<List<ItemDetailModel>> getItemsByIds(List<String> ids) async {
    try {
      final responses = await Future.wait(
        ids.map((id) => getItemById(id)),
        eagerError: false, // Jika satu gagal, yang lain tetap berjalan
      );

      return responses.whereType<ItemDetailModel>().toList();
    } catch (e) {
      // Jika Future.wait itu sendiri gagal (jarang terjadi), lempar exception.
      throw ServerException(message: 'Gagal memuat beberapa item.');
    }
  }
}
