// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qris_payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QrisPaymentModel _$QrisPaymentModelFromJson(Map<String, dynamic> json) =>
    QrisPaymentModel(
      method: json['method'] as String?,
      payload: json['payload'] as String?,
    );

Map<String, dynamic> _$QrisPaymentModelToJson(QrisPaymentModel instance) =>
    <String, dynamic>{
      'method': instance.method,
      'payload': instance.payload,
    };
