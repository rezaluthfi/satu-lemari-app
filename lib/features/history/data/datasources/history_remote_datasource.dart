// lib/features/history/data/datasources/history_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:satulemari/core/constants/app_urls.dart';
import 'package:satulemari/core/errors/exceptions.dart';
import 'package:satulemari/features/history/data/models/request_detail_model.dart';
import 'package:satulemari/features/history/data/models/request_item_model.dart';

abstract class HistoryRemoteDataSource {
  Future<List<RequestItemModel>> getMyRequests({
    required String type,
    int page = 1,
    int limit = 10,
  });
  Future<RequestDetailModel> getRequestDetail(String id);
  Future<void> deleteRequest(String id, String status);
}

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final Dio dio;
  HistoryRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<RequestItemModel>> getMyRequests({
    required String type,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await dio.get(
        AppUrls.myRequests,
        queryParameters: {
          'type': type,
          'page': page,
          'limit': limit,
        },
      );

      // 1. Pengecekan keamanan untuk respons data.
      //    Pastikan field 'data' ada dan merupakan sebuah List.
      final dynamic responseData = response.data['data'];
      if (responseData is! List) {
        // Jika backend mengembalikan null atau bukan list saat kosong,
        // kita anggap saja sebagai list kosong untuk mencegah crash.
        debugPrint(
            "[HistoryDataSource] 'data' field is not a List for type '$type'. Returning empty list.");
        return [];
      }

      final List<dynamic> data = responseData;

      // 2. Parsing yang aman di dalam List.from.
      //    Ini lebih eksplisit daripada .map().toList()
      return List<RequestItemModel>.from(
          data.map((json) => RequestItemModel.fromJson(json)));
    } on DioException catch (e) {
      // Menangkap error dari server (seperti 4xx, 5xx)
      final message = e.response?.data?['message'] ?? 'Gagal memuat riwayat';
      throw ServerException(message: message);
    } catch (e, stacktrace) {
      // 3. Menangkap SEMUA error lainnya, terutama error parsing (misal: TypeError, FormatException)
      //    dan mengubahnya menjadi ServerException yang bisa ditangani oleh Repository dan BLoC.
      debugPrint("[HistoryDataSource] Parsing error for type '$type': $e");
      debugPrint(stacktrace.toString());
      throw ServerException(message: 'Gagal memproses data riwayat.');
    }
  }

  @override
  Future<RequestDetailModel> getRequestDetail(String id) async {
    try {
      final response = await dio.get('${AppUrls.requests}/$id');
      return RequestDetailModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException(
            message: e.response?.data['message'] ??
                'Detail permintaan tidak ditemukan');
      }
      throw ServerException(
          message: e.response?.data['message'] ?? 'Gagal memuat detail');
    }
  }

  @override
  Future<void> deleteRequest(String id, String status) async {
    try {
      // Tentukan tipe delete berdasarkan status request:
      // - Jika statusnya 'pending' = hard delete (hapus permanen)
      // - Jika statusnya 'approve', 'rejected', 'completed' = soft delete (hapus dari user saja)
      final bool isHardDelete = status.toLowerCase() == 'pending';

      // Panggil endpoint delete tanpa query parameter
      // Backend akan menentukan jenis delete berdasarkan status internal request
      await dio.delete('${AppUrls.requests}/$id');

      debugPrint(
          '[HistoryDataSource] ${isHardDelete ? 'Hard' : 'Soft'} delete completed for request $id with status $status');
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ?? 'Gagal menghapus permintaan';
      throw ServerException(message: message);
    }
  }
}
