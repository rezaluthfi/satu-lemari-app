import 'package:json_annotation/json_annotation.dart';
import 'package:satulemari/features/order/domain/entities/order_item.dart';

part 'order_item_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.id,
    required super.status,
    required super.type,
    required super.totalAmount,
    required super.createdAt,
    required super.itemName,
    super.itemImageUrl,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);
}
