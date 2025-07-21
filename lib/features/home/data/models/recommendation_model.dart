import 'package:json_annotation/json_annotation.dart';

part 'recommendation_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class RecommendationModel {
  final String type;
  final String title;
  final String description;
  final String reason;
  final double score;
  final RecommendationDataModel data;

  RecommendationModel({
    required this.type,
    required this.title,
    required this.description,
    required this.reason,
    required this.score,
    required this.data,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) =>
      _$RecommendationModelFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationModelToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class RecommendationDataModel {
  final String? itemId;
  final String? name;
  final String? category;
  final String? size;
  final String? condition;
  final double? price;

  @JsonKey(defaultValue: [])
  final List<String> images;

  @JsonKey(defaultValue: [])
  final List<String> tags;

  RecommendationDataModel({
    this.itemId,
    this.name,
    this.category,
    this.size,
    this.condition,
    this.price,
    required this.images,
    required this.tags,
  });

  factory RecommendationDataModel.fromJson(Map<String, dynamic> json) =>
      _$RecommendationDataModelFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationDataModelToJson(this);
}
