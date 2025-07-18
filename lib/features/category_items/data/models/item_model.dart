import 'package:json_annotation/json_annotation.dart';

part 'item_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ItemModel {
  final String id;
  final String? name;
  final String? description;
  final String? categoryId;
  final String? type;

  final String? size;
  final String? condition;
  final int? availableQuantity;
  final double? price;

  @JsonKey(defaultValue: [])
  final List<String> images;

  ItemModel({
    required this.id,
    this.name,
    this.description,
    this.categoryId,
    this.type,
    this.size,
    this.condition,
    this.availableQuantity,
    this.price,
    required this.images,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) =>
      _$ItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$ItemModelToJson(this);
}
