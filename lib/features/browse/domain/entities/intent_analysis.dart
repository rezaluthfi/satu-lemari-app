// lib/features/browse/domain/entities/intent_analysis.dart

import 'package:equatable/equatable.dart';

class IntentAnalysis extends Equatable {
  final IntentFilters filters;
  final String originalQuery;

  const IntentAnalysis({
    required this.filters,
    required this.originalQuery,
  });

  @override
  List<Object?> get props => [filters, originalQuery];
}

class IntentFilters extends Equatable {
  final String? search;
  final String? categoryId;
  final String? size;
  final String? color;
  final String? condition;
  final int? maxPrice;

  const IntentFilters({
    this.search,
    this.categoryId,
    this.size,
    this.color,
    this.condition,
    this.maxPrice,
  });

  @override
  List<Object?> get props => [
        search,
        categoryId,
        size,
        color,
        condition,
        maxPrice,
      ];
}
