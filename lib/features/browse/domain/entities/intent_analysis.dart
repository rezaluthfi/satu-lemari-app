// lib/features/browse/domain/entities/intent_analysis.dart

import 'package:equatable/equatable.dart';

class IntentAnalysis extends Equatable {
  final IntentFilters filters;
  final String query;

  const IntentAnalysis({
    required this.filters,
    required this.query,
  });

  @override
  List<Object?> get props => [filters, query];
}

class IntentFilters extends Equatable {
  final String? search;
  final String? categoryId; // Diubah dari nama kategori menjadi ID
  final String? size;
  final int? maxPrice;
  // Anda bisa tambahkan properti lain seperti color atau condition jika akan digunakan di filter
  // final String? color;
  // final String? condition;

  const IntentFilters({
    this.search,
    this.categoryId,
    this.size,
    this.maxPrice,
  });

  @override
  List<Object?> get props => [search, categoryId, size, maxPrice];
}
