import 'package:dio/dio.dart';
import 'package:satulemari/core/constants/app_urls.dart';
import 'package:satulemari/core/errors/exceptions.dart';
import 'package:satulemari/features/request/data/models/create_request_model.dart';
import 'package:satulemari/features/request/data/models/create_request_response_model.dart';

abstract class RequestRemoteDataSource {
  Future<CreateRequestResponseModel> createRequest(CreateRequestModel request);
}

class RequestRemoteDataSourceImpl implements RequestRemoteDataSource {
  final Dio dio;
  RequestRemoteDataSourceImpl({required this.dio});

  @override
  Future<CreateRequestResponseModel> createRequest(
      CreateRequestModel request) async {
    try {
      final response = await dio.post(AppUrls.requests, data: request.toJson());
      return CreateRequestResponseModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      String message = 'Gagal membuat permintaan';
      if (e.response?.data != null && e.response!.data['error'] is Map) {
        message = e.response!.data['error']['message'] ?? message;
      }
      throw ServerException(message: message);
    }
  }
}
