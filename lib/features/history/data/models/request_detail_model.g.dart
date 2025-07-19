// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestDetailModel _$RequestDetailModelFromJson(Map<String, dynamic> json) =>
    RequestDetailModel(
      id: json['id'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      rejectionReason: json['rejection_reason'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      item: ItemInRequestModel.fromJson(json['item'] as Map<String, dynamic>),
      partner: PartnerInRequestModel.fromJson(
          json['partner'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RequestDetailModelToJson(RequestDetailModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'status': instance.status,
      'rejection_reason': instance.rejectionReason,
      'created_at': instance.createdAt.toIso8601String(),
      'item': instance.item,
      'partner': instance.partner,
    };

ItemInRequestModel _$ItemInRequestModelFromJson(Map<String, dynamic> json) =>
    ItemInRequestModel(
      id: json['id'] as String,
      name: json['name'] as String,
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ItemInRequestModelToJson(ItemInRequestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'images': instance.images,
    };

PartnerInRequestModel _$PartnerInRequestModelFromJson(
        Map<String, dynamic> json) =>
    PartnerInRequestModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      username: json['username'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$PartnerInRequestModelToJson(
        PartnerInRequestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'username': instance.username,
      'phone': instance.phone,
      'address': instance.address,
    };
