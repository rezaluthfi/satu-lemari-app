import 'package:json_annotation/json_annotation.dart';

part 'cancel_order_response_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class CancelOrderResponseModel {
  final String message;
  final String orderId;
  final String status;

  CancelOrderResponseModel({
    required this.message,
    required this.orderId,
    required this.status,
  });

  factory CancelOrderResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CancelOrderResponseModelFromJson(json);
}
