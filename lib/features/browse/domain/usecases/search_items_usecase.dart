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
  });

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
      ];
}
