import 'package:json_annotation/json_annotation.dart';
import 'package:satulemari/features/order/domain/entities/create_order_response.dart';
import 'package:satulemari/features/order/domain/entities/order_detail.dart';

part 'order_detail_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class CreateOrderResponseModel {
  final String orderId;
  final DateTime expiresAt;
  final int itemPrice;
  final ShippingDetailsModel shippingDetails;
  final int shippingFee;
  final String status;
  final int totalAmount;
  final QrisInfoModel? qris;

  CreateOrderResponseModel({
    required this.orderId,
    required this.expiresAt,
    required this.itemPrice,
    required this.shippingDetails,
    required this.shippingFee,
    required this.status,
    required this.totalAmount,
    this.qris,
  });

  factory CreateOrderResponseModel.fromJson(Map<String, dynamic> json) {
    // Membaca dari root 'data' yang ada di respons JSON
    return _$CreateOrderResponseModelFromJson(
        json['data'] as Map<String, dynamic>);
  }

  CreateOrderResponseEntity toEntity() {
    return CreateOrderResponseEntity(
      orderId: orderId,
      expiresAt: expiresAt,
      itemPrice: itemPrice,
      shippingFee: shippingFee,
      status: status,
      totalAmount: totalAmount,
      qrisPayload: qris?.payload,
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class ShippingDetailsModel {
  final int buyerFee;
  final String method;
  final int sellerFee;

  ShippingDetailsModel({
    required this.buyerFee,
    required this.method,
    required this.sellerFee,
  });

  factory ShippingDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$ShippingDetailsModelFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class QrisInfoModel {
  final String method;
  final String payload;

  QrisInfoModel({required this.method, required this.payload});

  factory QrisInfoModel.fromJson(Map<String, dynamic> json) =>
      _$QrisInfoModelFromJson(json);
}

@JsonSerializable(createToJson: false, explicitToJson: true)
class GetOrderDetailResponse {
  @JsonKey(name: 'order')
  final OrderDataModel order;
  @JsonKey(name: 'payment')
  final PaymentDataModel payment;

  GetOrderDetailResponse({required this.order, required this.payment});

  factory GetOrderDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$GetOrderDetailResponseFromJson(json);

  OrderDetail toEntity() {
    return OrderDetail(
      id: order.id,
      status: order.status,
      shippingMethod: order.shippingMethod,
      itemPrice: order.itemPrice,
      shippingFee: order.shippingFee,
      totalAmount: order.totalAmount,
      notes: order.notes,
      createdAt: order.createdAt,
      expiresAt: order.expiresAt,
      payment: payment.toEntity(),
      itemId: order.itemId,
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class OrderDataModel {
  final String id;
  final String status;
  final String shippingMethod;
  final int itemPrice;
  final int shippingFee;
  final int totalAmount;
  final String? notes;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String itemId;

  OrderDataModel({
    required this.id,
    required this.status,
    required this.shippingMethod,
    required this.itemPrice,
    required this.shippingFee,
    required this.totalAmount,
    this.notes,
    required this.createdAt,
    required this.expiresAt,
    required this.itemId,
  });

  factory OrderDataModel.fromJson(Map<String, dynamic> json) =>
      _$OrderDataModelFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class PaymentDataModel {
  final String id;
  final String status;
  final String method;
  final String? qrisPayload;
  final DateTime? paidAt;

  PaymentDataModel({
    required this.id,
    required this.status,
    required this.method,
    this.qrisPayload,
    this.paidAt,
  });

  factory PaymentDataModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentDataModelFromJson(json);

  PaymentDetail toEntity() {
    return PaymentDetail(
      id: id,
      status: status,
      method: method,
      qrisPayload: qrisPayload,
      paidAt: paidAt,
    );
  }
}
