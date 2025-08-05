// lib/features/browse/domain/usecases/search_items_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/features/browse/domain/repositories/browse_repository.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/category_items/domain/entities/item_entity.dart';

class SearchItemsUseCase implements UseCase<List<Item>, SearchItemsParams> {
  final BrowseRepository repository;
  SearchItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Item>>> call(SearchItemsParams params) async {
    return await repository.searchItems(params);
  }
}

class SearchItemsParams extends Equatable {
  final String type; // 'donation' or 'rental'
  final String? query;
  final String? categoryId;
  final String? size;
  final String? color;
  final String? condition;
  final String? sortBy;
  final String? sortOrder;
  final String? city;
  final double? minPrice;
  final double? maxPrice;
  final int page;
  final int limit;

  const SearchItemsParams({
    required this.type,
    this.query,
    this.categoryId,
    this.size,
    this.color,
    this.condition,
    this.sortBy,
    this.sortOrder,
    this.city,
    this.minPrice,
    this.maxPrice,
    this.page = 1,
    this.limit = 10,
  });

  /// Calculate offset from page and limit
  int get offset => (page - 1) * limit;

  /// Create a copy with new pagination parameters
  SearchItemsParams copyWithPagination({int? page, int? limit}) {
    return SearchItemsParams(
      type: type,
      query: query,
      categoryId: categoryId,
      size: size,
      color: color,
      condition: condition,
      sortBy: sortBy,
      sortOrder: sortOrder,
      city: city,
      minPrice: minPrice,
      maxPrice: maxPrice,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  @override
  List<Object?> get props => [
        type,
        query,
        categoryId,
        size,
        color,
        condition,
        sortBy,
        sortOrder,
        city,
        minPrice,
        maxPrice,
        page,
        limit,
      ];
}
