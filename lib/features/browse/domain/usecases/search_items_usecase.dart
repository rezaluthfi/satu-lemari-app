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

  const SearchItemsParams({
    required this.type,
    this.query,
    this.categoryId,
    this.size,
  });

  @override
  List<Object?> get props => [type, query, categoryId, size];

  SearchItemsParams copyWith({
    String? type,
    String? query,
    String? categoryId,
    String? size,
  }) {
    return SearchItemsParams(
      type: type ?? this.type,
      query: query ?? this.query,
      categoryId: categoryId ?? this.categoryId,
      size: size ?? this.size,
    );
  }
}
