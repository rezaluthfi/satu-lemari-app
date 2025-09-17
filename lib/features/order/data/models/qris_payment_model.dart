import 'package:json_annotation/json_annotation.dart';

part 'qris_payment_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class QrisPaymentModel {
  final String? method;
  final String? payload;

  QrisPaymentModel({this.method, this.payload});

  factory QrisPaymentModel.fromJson(Map<String, dynamic> json) =>
      _$QrisPaymentModelFromJson(json);
  Map<String, dynamic> toJson() => _$QrisPaymentModelToJson(this);
}
