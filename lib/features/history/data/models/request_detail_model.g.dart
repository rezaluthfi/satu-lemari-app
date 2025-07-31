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
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      item: ItemInRequestModel.fromJson(json['item'] as Map<String, dynamic>),
      partner: PartnerInRequestModel.fromJson(
          json['partner'] as Map<String, dynamic>),
      reason: json['reason'] as String?,
      pickupDate: json['pickup_date'] == null
          ? null
          : DateTime.parse(json['pickup_date'] as String),
      returnDate: json['return_date'] == null
          ? null
          : DateTime.parse(json['return_date'] as String),
    );

Map<String, dynamic> _$RequestDetailModelToJson(RequestDetailModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'status': instance.status,
      'rejection_reason': instance.rejectionReason,
      'created_at': instance.createdAt.toIso8601String(),
      'item': instance.item.toJson(),
      'partner': instance.partner.toJson(),
      'reason': instance.reason,
      'pickup_date': instance.pickupDate?.toIso8601String(),
      'return_date': instance.returnDate?.toIso8601String(),
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
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PartnerInRequestModelToJson(
        PartnerInRequestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'username': instance.username,
      'phone': instance.phone,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
