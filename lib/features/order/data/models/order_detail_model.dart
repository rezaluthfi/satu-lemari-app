import 'package:json_annotation/json_annotation.dart';
import 'package:satulemari/features/order/data/models/qris_payment_model.dart';
import 'package:satulemari/features/order/domain/entities/order_detail.dart';

part 'order_detail_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class CreateOrderResponseModel {
  @JsonKey(name: 'order_id')
  final String orderId;
  final QrisPaymentModel? qris;

  CreateOrderResponseModel({required this.orderId, this.qris});

  factory CreateOrderResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderResponseModelFromJson(json);
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
    required this.itemId, // <-- Diubah
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
