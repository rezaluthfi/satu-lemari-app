import 'package:json_annotation/json_annotation.dart';

part 'order_item_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class OrderItemModel {
  final String id;
  final String status;
  final String type;
  final int totalAmount;
  final DateTime createdAt;
  final String itemId;

  OrderItemModel({
    required this.id,
    required this.status,
    required this.type,
    required this.totalAmount,
    required this.createdAt,
    required this.itemId,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);
}
