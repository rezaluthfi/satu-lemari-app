// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateOrderResponseModel _$CreateOrderResponseModelFromJson(
        Map<String, dynamic> json) =>
    CreateOrderResponseModel(
      orderId: json['order_id'] as String,
      qris: json['qris'] == null
          ? null
          : QrisPaymentModel.fromJson(json['qris'] as Map<String, dynamic>),
    );

GetOrderDetailResponse _$GetOrderDetailResponseFromJson(
        Map<String, dynamic> json) =>
    GetOrderDetailResponse(
      order: OrderDataModel.fromJson(json['order'] as Map<String, dynamic>),
      payment:
          PaymentDataModel.fromJson(json['payment'] as Map<String, dynamic>),
    );

OrderDataModel _$OrderDataModelFromJson(Map<String, dynamic> json) =>
    OrderDataModel(
      id: json['id'] as String,
      status: json['status'] as String,
      shippingMethod: json['shipping_method'] as String,
      itemPrice: (json['item_price'] as num).toInt(),
      shippingFee: (json['shipping_fee'] as num).toInt(),
      totalAmount: (json['total_amount'] as num).toInt(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );

PaymentDataModel _$PaymentDataModelFromJson(Map<String, dynamic> json) =>
    PaymentDataModel(
      id: json['id'] as String,
      status: json['status'] as String,
      method: json['method'] as String,
      qrisPayload: json['qris_payload'] as String?,
      paidAt: json['paid_at'] == null
          ? null
          : DateTime.parse(json['paid_at'] as String),
    );
