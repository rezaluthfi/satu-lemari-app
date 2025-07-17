// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthRequestModel _$AuthRequestModelFromJson(Map<String, dynamic> json) =>
    AuthRequestModel(
      token: json['token'] as String,
      type: json['type'] as String,
      platform: json['platform'] as String? ?? 'mobile',
      username: json['username'] as String?,
    );

Map<String, dynamic> _$AuthRequestModelToJson(AuthRequestModel instance) =>
    <String, dynamic>{
      'token': instance.token,
      'type': instance.type,
      'platform': instance.platform,
      if (instance.username case final value?) 'username': value,
    };
