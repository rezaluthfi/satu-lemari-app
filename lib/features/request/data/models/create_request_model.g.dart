// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateRequestModel _$CreateRequestModelFromJson(Map<String, dynamic> json) =>
    CreateRequestModel(
      itemId: json['item_id'] as String,
      quantity: (json['quantity'] as num).toInt(),
      reason: json['reason'] as String?,
      pickupDate: json['pickup_date'] as String?,
      returnDate: json['return_date'] as String?,
    );

Map<String, dynamic> _$CreateRequestModelToJson(CreateRequestModel instance) =>
    <String, dynamic>{
      'item_id': instance.itemId,
      'quantity': instance.quantity,
      if (instance.reason case final value?) 'reason': value,
      if (instance.pickupDate case final value?) 'pickup_date': value,
      if (instance.returnDate case final value?) 'return_date': value,
    };
