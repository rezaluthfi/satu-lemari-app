// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponseModel _$AuthResponseModelFromJson(Map<String, dynamic> json) =>
    AuthResponseModel(
      success: json['success'] as bool,
      data: json['data'] == null
          ? null
          : AuthDataModel.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$AuthResponseModelToJson(AuthResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
      'message': instance.message,
    };

AuthDataModel _$AuthDataModelFromJson(Map<String, dynamic> json) =>
    AuthDataModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['access_token'] as String?,
      tokenType: json['token_type'] as String?,
      expiresIn: (json['expires_in'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AuthDataModelToJson(AuthDataModel instance) =>
    <String, dynamic>{
      'user': instance.user,
      'access_token': instance.accessToken,
      'token_type': instance.tokenType,
      'expires_in': instance.expiresIn,
    };
