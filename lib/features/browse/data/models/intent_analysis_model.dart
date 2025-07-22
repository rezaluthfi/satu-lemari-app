// lib/features/browse/data/models/intent_analysis_model.dart

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'intent_analysis_model.g.dart';

@JsonSerializable()
class IntentAnalysisResponseModel extends Equatable {
  final bool success;
  final String message;
  final IntentAnalysisDataModel data;

  const IntentAnalysisResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory IntentAnalysisResponseModel.fromJson(Map<String, dynamic> json) =>
      _$IntentAnalysisResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$IntentAnalysisResponseModelToJson(this);

  @override
  List<Object?> get props => [success, message, data];
}

@JsonSerializable()
class IntentAnalysisDataModel extends Equatable {
  final String intent;
  final double confidence;
  final IntentEntitiesModel entities;
  final IntentFiltersModel filters;
  final String query;
  final List<String> suggestions;

  const IntentAnalysisDataModel({
    required this.intent,
    required this.confidence,
    required this.entities,
    required this.filters,
    required this.query,
    required this.suggestions,
  });

  factory IntentAnalysisDataModel.fromJson(Map<String, dynamic> json) =>
      _$IntentAnalysisDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$IntentAnalysisDataModelToJson(this);

  @override
  List<Object?> get props =>
      [intent, confidence, entities, filters, query, suggestions];
}

@JsonSerializable()
class IntentEntitiesModel extends Equatable {
  final String? category;
  final String? color;
  final String? size;
  @JsonKey(name: 'price_range')
  final String? priceRange;
  final String? condition;

  const IntentEntitiesModel({
    this.category,
    this.color,
    this.size,
    this.priceRange,
    this.condition,
  });

  factory IntentEntitiesModel.fromJson(Map<String, dynamic> json) =>
      _$IntentEntitiesModelFromJson(json);

  Map<String, dynamic> toJson() => _$IntentEntitiesModelToJson(this);

  @override
  List<Object?> get props => [category, color, size, priceRange, condition];
}

@JsonSerializable()
class IntentFiltersModel extends Equatable {
  final String? search;
  final String? color;
  final String? size;
  final String? condition;
  @JsonKey(name: 'max_price')
  final int? maxPrice;

  const IntentFiltersModel({
    this.search,
    this.color,
    this.size,
    this.condition,
    this.maxPrice,
  });

  factory IntentFiltersModel.fromJson(Map<String, dynamic> json) =>
      _$IntentFiltersModelFromJson(json);

  Map<String, dynamic> toJson() => _$IntentFiltersModelToJson(this);

  @override
  List<Object?> get props => [search, color, size, condition, maxPrice];
}
