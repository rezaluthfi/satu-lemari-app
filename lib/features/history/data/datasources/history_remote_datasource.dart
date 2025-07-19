import 'package:dio/dio.dart';
import 'package:satulemari/core/constants/app_urls.dart';
import 'package:satulemari/core/errors/exceptions.dart';
import 'package:satulemari/features/history/data/models/request_detail_model.dart';
import 'package:satulemari/features/history/data/models/request_item_model.dart';

abstract class HistoryRemoteDataSource {
  Future<List<RequestItemModel>> getMyRequests({required String type});
  Future<RequestDetailModel> getRequestDetail(String id);
}

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final Dio dio;
  HistoryRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<RequestItemModel>> getMyRequests({required String type}) async {
    try {
      final response = await dio.get(
        AppUrls.myRequests,
        queryParameters: {'type': type},
      );
      final List<dynamic> data = response.data['data'];
      return data.map((json) => RequestItemModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data['message'] ?? 'Gagal memuat riwayat');
    }
  }

  @override
  Future<RequestDetailModel> getRequestDetail(String id) async {
    try {
      final response = await dio.get('${AppUrls.requests}/$id');
      return RequestDetailModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data['message'] ?? 'Gagal memuat detail');
    }
  }
}
