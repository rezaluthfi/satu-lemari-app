// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItemModel _$OrderItemModelFromJson(Map<String, dynamic> json) =>
    OrderItemModel(
      id: json['id'] as String,
      status: json['status'] as String,
      type: json['type'] as String,
      totalAmount: (json['total_amount'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      itemName: json['item_name'] as String,
      itemImageUrl: json['item_image_url'] as String?,
    );
