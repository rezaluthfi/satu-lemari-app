import 'package:dio/dio.dart';
import 'package:satulemari/core/constants/app_urls.dart';
import 'package:satulemari/core/errors/exceptions.dart';
import 'package:satulemari/features/order/data/models/cancel_order_response_model.dart';
import 'package:satulemari/features/order/data/models/create_order_request_model.dart';
import 'package:satulemari/features/order/data/models/order_detail_model.dart';
import 'package:satulemari/features/order/data/models/order_item_model.dart';

abstract class OrderRemoteDataSource {
  Future<CreateOrderResponseModel> createOrder(CreateOrderRequestModel request);
  Future<GetOrderDetailResponse> getOrderDetail(String orderId);
  Future<List<OrderItemModel>> getMyOrders();
  Future<CancelOrderResponseModel> cancelOrder(String orderId);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final Dio dio;
  OrderRemoteDataSourceImpl({required this.dio});

  @override
  Future<CreateOrderResponseModel> createOrder(
      CreateOrderRequestModel request) async {
    try {
      final response = await dio.post(AppUrls.orders, data: request.toJson());
      return CreateOrderResponseModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      String message = 'Gagal membuat pesanan';
      if (e.response?.data != null && e.response!.data['error'] is Map) {
        message = e.response!.data['error']['message'] ?? message;
      }
      throw ServerException(message: message);
    }
  }

  @override
  Future<GetOrderDetailResponse> getOrderDetail(String orderId) async {
    try {
      final response = await dio.get('${AppUrls.orders}/$orderId');
      return GetOrderDetailResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Pesanan tidak ditemukan.');
      }
      String message = 'Gagal mengambil detail pesanan';
      if (e.response?.data != null && e.response!.data['error'] is Map) {
        message = e.response!.data['error']['message'] ?? message;
      }
      throw ServerException(message: message);
    }
  }

  @override
  Future<List<OrderItemModel>> getMyOrders() async {
    try {
      final response = await dio.get(AppUrls.orders);
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => OrderItemModel.fromJson(json)).toList();
    } on DioException catch (e) {
      String message = 'Gagal mengambil riwayat pesanan';
      if (e.response?.data != null && e.response!.data['error'] is Map) {
        message = e.response!.data['error']['message'] ?? message;
      }
      throw ServerException(message: message);
    }
  }

  @override
  Future<CancelOrderResponseModel> cancelOrder(String orderId) async {
    try {
      final response = await dio.delete('${AppUrls.orders}/$orderId');
      return CancelOrderResponseModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      String message = 'Gagal membatalkan pesanan';
      if (e.response?.data != null && e.response!.data['error'] is Map) {
        message = e.response!.data['error']['message'] ?? message;
      }
      throw ServerException(message: message);
    }
  }
}
