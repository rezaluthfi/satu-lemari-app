import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:satulemari/core/constants/app_urls.dart';
import 'package:satulemari/core/errors/exceptions.dart';
import 'package:satulemari/features/profile/data/models/dashboard_stats_model.dart';
import 'package:satulemari/features/profile/data/models/profile_model.dart';
import 'package:satulemari/features/profile/data/models/update_profile_request.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<DashboardStatsModel> getDashboardStats();
  Future<ProfileModel> updateProfile(UpdateProfileRequest request);
  Future<void> deleteAccount();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl({required this.dio});

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final response = await dio.get(AppUrls.userProfile);
      return ProfileModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['error']?['message'] ??
            e.response?.data['message'] ??
            'Gagal memuat profil',
      );
    }
  }

  @override
  Future<DashboardStatsModel> getDashboardStats() async {
    try {
      final response = await dio.get(AppUrls.userDashboard);
      return DashboardStatsModel.fromJson(response.data['data']['stats']);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['error']?['message'] ??
            e.response?.data['message'] ??
            'Gagal memuat dashboard',
      );
    }
  }

  @override
  Future<ProfileModel> updateProfile(UpdateProfileRequest request) async {
    try {
      // PERBAIKAN: Selalu gunakan multipart/form-data untuk semua update profile
      final Map<String, dynamic> data = {};

      // Tambahkan field text sebagai string
      if (request.fullName != null) data['full_name'] = request.fullName!;
      if (request.phone != null) data['phone'] = request.phone!;
      if (request.address != null) data['address'] = request.address!;
      if (request.city != null) data['city'] = request.city!;
      if (request.description != null)
        data['description'] = request.description!;
      if (request.latitude != null)
        data['latitude'] = request.latitude!.toString();
      if (request.longitude != null)
        data['longitude'] = request.longitude!.toString();

      // Jika ada file foto, tambahkan sebagai MultipartFile
      if (request.photoFile != null) {
        final file = File(request.photoFile!.path);

        // Deteksi MIME type berdasarkan file extension
        String? mimeType = lookupMimeType(file.path);

        // Fallback jika MIME type tidak terdeteksi
        if (mimeType == null) {
          final extension = file.path.split('.').last.toLowerCase();
          switch (extension) {
            case 'jpg':
            case 'jpeg':
              mimeType = 'image/jpeg';
              break;
            case 'png':
              mimeType = 'image/png';
              break;
            case 'gif':
              mimeType = 'image/gif';
              break;
            case 'webp':
              mimeType = 'image/webp';
              break;
            default:
              mimeType = 'image/jpeg'; // Default ke JPEG
          }
        }

        data['photo'] = await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
          contentType: MediaType.parse(mimeType),
        );
      }

      // Selalu gunakan FormData untuk semua request update profile
      final formData = FormData.fromMap(data);

      final response = await dio.put(
        AppUrls.userProfile,
        data: formData,
        // Jangan set Content-Type manual, biarkan Dio yang handle
      );

      return ProfileModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      String errorMessage = 'Gagal memperbarui profil';
      if (e.response?.data != null && e.response!.data is Map) {
        final errorData = e.response!.data;
        errorMessage = errorData['error']?['message'] ??
            errorData['message'] ??
            errorMessage;
      }
      throw ServerException(message: errorMessage);
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await dio.delete(AppUrls.userProfile);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['error']?['message'] ??
            e.response?.data['message'] ??
            'Gagal menghapus akun',
      );
    }
  }
}
