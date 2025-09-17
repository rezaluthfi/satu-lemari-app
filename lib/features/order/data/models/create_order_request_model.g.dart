// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_order_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateOrderRequestModel _$CreateOrderRequestModelFromJson(
        Map<String, dynamic> json) =>
    CreateOrderRequestModel(
      itemId: json['item_id'] as String,
      requestId: json['request_id'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      shippingMethod: json['shipping_method'] as String,
      paymentMethod: json['payment_method'] as String?,
      notes: json['notes'] as String?,
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      sellerDeliveryChoice: json['seller_delivery_choice'] as String?,
    );

Map<String, dynamic> _$CreateOrderRequestModelToJson(
        CreateOrderRequestModel instance) =>
    <String, dynamic>{
      'item_id': instance.itemId,
      if (instance.requestId case final value?) 'request_id': value,
      'quantity': instance.quantity,
      'shipping_method': instance.shippingMethod,
      if (instance.paymentMethod case final value?) 'payment_method': value,
      if (instance.notes case final value?) 'notes': value,
      if (instance.weightKg case final value?) 'weight_kg': value,
      if (instance.sellerDeliveryChoice case final value?)
        'seller_delivery_choice': value,
    };
