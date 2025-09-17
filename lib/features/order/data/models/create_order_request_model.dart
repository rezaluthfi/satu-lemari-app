import 'package:json_annotation/json_annotation.dart';

part 'create_order_request_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class CreateOrderRequestModel {
  final String itemId;
  final String? requestId;
  final int quantity;
  final String shippingMethod;
  final String? paymentMethod;
  final String? notes;

  final double? weightKg;
  final String? sellerDeliveryChoice;

  CreateOrderRequestModel({
    required this.itemId,
    this.requestId,
    required this.quantity,
    required this.shippingMethod,
    this.paymentMethod,
    this.notes,
    this.weightKg,
    this.sellerDeliveryChoice,
  });

  factory CreateOrderRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreateOrderRequestModelToJson(this);
}
