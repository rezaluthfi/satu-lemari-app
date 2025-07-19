// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemDetailModel _$ItemDetailModelFromJson(Map<String, dynamic> json) =>
    ItemDetailModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      size: json['size'] as String?,
      color: json['color'] as String?,
      type: json['type'] as String,
      availableQuantity: (json['available_quantity'] as num).toInt(),
      condition: json['condition'] as String,
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      partner: PartnerModel.fromJson(json['partner'] as Map<String, dynamic>),
      category:
          CategoryInfoModel.fromJson(json['category'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ItemDetailModelToJson(ItemDetailModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'size': instance.size,
      'color': instance.color,
      'type': instance.type,
      'available_quantity': instance.availableQuantity,
      'condition': instance.condition,
      'images': instance.images,
      'partner': instance.partner,
      'category': instance.category,
    };

PartnerModel _$PartnerModelFromJson(Map<String, dynamic> json) => PartnerModel(
      id: json['id'] as String,
      username: json['username'] as String,
      fullName: json['full_name'] as String?,
      photo: json['photo'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PartnerModelToJson(PartnerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'full_name': instance.fullName,
      'photo': instance.photo,
      'phone': instance.phone,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

CategoryInfoModel _$CategoryInfoModelFromJson(Map<String, dynamic> json) =>
    CategoryInfoModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$CategoryInfoModelToJson(CategoryInfoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
