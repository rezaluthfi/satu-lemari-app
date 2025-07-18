// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemModel _$ItemModelFromJson(Map<String, dynamic> json) => ItemModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      description: json['description'] as String?,
      categoryId: json['category_id'] as String?,
      type: json['type'] as String?,
      size: json['size'] as String?,
      condition: json['condition'] as String?,
      availableQuantity: (json['available_quantity'] as num?)?.toInt(),
      price: (json['price'] as num?)?.toDouble(),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

Map<String, dynamic> _$ItemModelToJson(ItemModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category_id': instance.categoryId,
      'type': instance.type,
      'size': instance.size,
      'condition': instance.condition,
      'available_quantity': instance.availableQuantity,
      'price': instance.price,
      'images': instance.images,
    };
