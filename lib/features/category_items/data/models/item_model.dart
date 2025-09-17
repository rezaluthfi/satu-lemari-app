import 'package:json_annotation/json_annotation.dart';
import 'package:satulemari/features/category_items/domain/entities/item_entity.dart';
import 'package:satulemari/features/home/domain/entities/recommendation.dart';

part 'item_model.g.dart';

String? _categoryNameFromJson(Map<String, dynamic>? categoryJson) {
  if (categoryJson != null && categoryJson.containsKey('name')) {
    return categoryJson['name'] as String?;
  }
  return null;
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ItemModel {
  final String id;
  final String? name;
  final String? description;
  final String? categoryId;

  @JsonKey(unknownEnumValue: ItemType.unknown)
  final ItemType? type;

  final String? size;
  final String? condition;
  final int? availableQuantity;
  final double? price;

  @JsonKey(defaultValue: [])
  final List<String> images;

  @JsonKey(
      name: 'category', fromJson: _categoryNameFromJson, includeToJson: false)
  final String? categoryName;

  final DateTime createdAt;

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
    this.categoryName,
    // --- TAMBAHKAN DI CONSTRUCTOR ---
    required this.createdAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) =>
      _$ItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ItemModelToJson(this);

  Item toEntity() {
    return Item(
      id: id,
      name: name ?? 'Tanpa Nama', // Fallback jika nama null
      type: type ?? ItemType.unknown, // Fallback jika type null
      imageUrl: images.isNotEmpty ? images.first : null,
      price: price,
      size: size,
      condition: condition,
      availableQuantity: availableQuantity,
      description: description,
      categoryName: categoryName,
      createdAt: createdAt,
    );
  }
}
