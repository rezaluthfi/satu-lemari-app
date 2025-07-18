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
  // Semua field yang mungkin hilang dari API dibuat opsional (nullable)
  final String? itemId;
  final String? name;
  final String? category;

  @JsonKey(
      defaultValue: []) // Beri default list kosong jika 'images' null atau tidak ada
  final List<String> images;

  @JsonKey(
      defaultValue: []) // Beri default list kosong jika 'tags' null atau tidak ada
  final List<String> tags;

  RecommendationDataModel({
    this.itemId, // Hapus 'required'
    this.name,
    this.category,
    required this.images, // Tetap required, karena defaultValue akan menanganinya
    required this.tags,
  });

  factory RecommendationDataModel.fromJson(Map<String, dynamic> json) =>
      _$RecommendationDataModelFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationDataModelToJson(this);
}
