// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestItemModel _$RequestItemModelFromJson(Map<String, dynamic> json) =>
    RequestItemModel(
      id: json['id'] as String,
      itemName: json['item_name'] as String,
      status: json['status'] as String,
      type: json['type'] as String,
      itemImages: (json['item_images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$RequestItemModelToJson(RequestItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'item_name': instance.itemName,
      'status': instance.status,
      'type': instance.type,
      'item_images': instance.itemImages,
      'created_at': instance.createdAt.toIso8601String(),
    };
