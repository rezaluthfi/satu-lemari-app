import 'package:json_annotation/json_annotation.dart';

part 'item_detail_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ItemDetailModel {
  final String id;
  final String? name;
  final String? description;
  final String? size;
  final String? color;
  final String? type;
  final int? availableQuantity;
  final String? condition;
  final double? price;
  final PartnerModel? partner;
  final CategoryInfoModel? category;

  @JsonKey(defaultValue: [])
  final List<String> images;
  final DateTime createdAt;

  ItemDetailModel({
    required this.id,
    this.name,
    this.description,
    this.size,
    this.color,
    this.type,
    this.availableQuantity,
    this.condition,
    this.price,
    required this.images,
    this.partner,
    this.category,
    required this.createdAt,
  });

  factory ItemDetailModel.fromJson(Map<String, dynamic> json) =>
      _$ItemDetailModelFromJson(json);
  Map<String, dynamic> toJson() => _$ItemDetailModelToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class PartnerModel {
  final String id;
  final String username;
  final String? fullName;
  final String? photo;
  final String? phone;
  final String? address;
  final double? latitude;
  final double? longitude;

  PartnerModel({
    required this.id,
    required this.username,
    this.fullName,
    this.photo,
    this.phone,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json) =>
      _$PartnerModelFromJson(json);
  Map<String, dynamic> toJson() => _$PartnerModelToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CategoryInfoModel {
  final String id;
  final String name;

  CategoryInfoModel({
    required this.id,
    required this.name,
  });

  factory CategoryInfoModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryInfoModelFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryInfoModelToJson(this);
}
