// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecommendationModel _$RecommendationModelFromJson(Map<String, dynamic> json) =>
    RecommendationModel(
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      reason: json['reason'] as String,
      score: (json['score'] as num).toDouble(),
      data: RecommendationDataModel.fromJson(
          json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RecommendationModelToJson(
        RecommendationModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'title': instance.title,
      'description': instance.description,
      'reason': instance.reason,
      'score': instance.score,
      'data': instance.data,
    };

RecommendationDataModel _$RecommendationDataModelFromJson(
        Map<String, dynamic> json) =>
    RecommendationDataModel(
      itemId: json['item_id'] as String?,
      name: json['name'] as String?,
      category: json['category'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
    );

Map<String, dynamic> _$RecommendationDataModelToJson(
        RecommendationDataModel instance) =>
    <String, dynamic>{
      'item_id': instance.itemId,
      'name': instance.name,
      'category': instance.category,
      'images': instance.images,
      'tags': instance.tags,
    };
