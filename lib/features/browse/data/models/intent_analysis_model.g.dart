// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intent_analysis_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IntentAnalysisResponseModel _$IntentAnalysisResponseModelFromJson(
        Map<String, dynamic> json) =>
    IntentAnalysisResponseModel(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: IntentAnalysisDataModel.fromJson(
          json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$IntentAnalysisResponseModelToJson(
        IntentAnalysisResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

IntentAnalysisDataModel _$IntentAnalysisDataModelFromJson(
        Map<String, dynamic> json) =>
    IntentAnalysisDataModel(
      intent: json['intent'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      entities: IntentEntitiesModel.fromJson(
          json['entities'] as Map<String, dynamic>),
      filters:
          IntentFiltersModel.fromJson(json['filters'] as Map<String, dynamic>),
      query: json['query'] as String,
      suggestions: (json['suggestions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$IntentAnalysisDataModelToJson(
        IntentAnalysisDataModel instance) =>
    <String, dynamic>{
      'intent': instance.intent,
      'confidence': instance.confidence,
      'entities': instance.entities,
      'filters': instance.filters,
      'query': instance.query,
      'suggestions': instance.suggestions,
    };

IntentEntitiesModel _$IntentEntitiesModelFromJson(Map<String, dynamic> json) =>
    IntentEntitiesModel(
      category: json['category'] as String?,
      color: json['color'] as String?,
      size: json['size'] as String?,
      priceRange: json['price_range'] as String?,
      condition: json['condition'] as String?,
    );

Map<String, dynamic> _$IntentEntitiesModelToJson(
        IntentEntitiesModel instance) =>
    <String, dynamic>{
      'category': instance.category,
      'color': instance.color,
      'size': instance.size,
      'price_range': instance.priceRange,
      'condition': instance.condition,
    };

IntentFiltersModel _$IntentFiltersModelFromJson(Map<String, dynamic> json) =>
    IntentFiltersModel(
      search: json['search'] as String?,
      color: json['color'] as String?,
      size: json['size'] as String?,
      condition: json['condition'] as String?,
      maxPrice: (json['max_price'] as num?)?.toInt(),
    );

Map<String, dynamic> _$IntentFiltersModelToJson(IntentFiltersModel instance) =>
    <String, dynamic>{
      'search': instance.search,
      'color': instance.color,
      'size': instance.size,
      'condition': instance.condition,
      'max_price': instance.maxPrice,
    };
