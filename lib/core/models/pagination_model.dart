// lib/core/models/pagination_model.dart

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pagination_model.g.dart';

/// Generic pagination response model that wraps paginated data
@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> extends Equatable {
  final List<T> data;
  final PaginationMeta meta;

  const PaginatedResponse({
    required this.data,
    required this.meta,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PaginatedResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$PaginatedResponseToJson(this, toJsonT);

  @override
  List<Object?> get props => [data, meta];
}

/// Pagination metadata containing information about the current page and total data
@JsonSerializable(fieldRename: FieldRename.snake)
class PaginationMeta extends Equatable {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginationMeta({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationMetaToJson(this);

  @override
  List<Object?> get props => [
        currentPage,
        perPage,
        total,
        lastPage,
        hasNextPage,
        hasPreviousPage,
      ];
}

/// Pagination parameters for API requests
class PaginationParams extends Equatable {
  final int page;
  final int limit;

  const PaginationParams({
    this.page = 1,
    this.limit = 10,
  });

  /// Calculate offset from page and limit
  int get offset => (page - 1) * limit;

  /// Create next page parameters
  PaginationParams nextPage() => PaginationParams(
        page: page + 1,
        limit: limit,
      );

  /// Create first page parameters
  PaginationParams firstPage() => PaginationParams(
        page: 1,
        limit: limit,
      );

  @override
  List<Object?> get props => [page, limit];
}

/// State management for infinite scroll pagination
class PaginationState<T> extends Equatable {
  final List<T> items;
  final PaginationParams currentParams;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final String? error;
  final String? loadMoreError;

  const PaginationState({
    this.items = const [],
    this.currentParams = const PaginationParams(),
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.error,
    this.loadMoreError,
  });

  PaginationState<T> copyWith({
    List<T>? items,
    PaginationParams? currentParams,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    String? error,
    String? loadMoreError,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      currentParams: currentParams ?? this.currentParams,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      error: error,
      loadMoreError: loadMoreError,
    );
  }

  /// Reset to initial state
  PaginationState<T> reset() => const PaginationState();

  /// Add new items to the list (for pagination)
  PaginationState<T> addItems(List<T> newItems, {bool hasReachedEnd = false}) {
    return copyWith(
      items: [...items, ...newItems],
      hasReachedEnd: hasReachedEnd,
      isLoadingMore: false,
      loadMoreError: null,
    );
  }

  /// Replace all items (for refresh)
  PaginationState<T> replaceItems(List<T> newItems, {bool hasReachedEnd = false}) {
    return copyWith(
      items: newItems,
      hasReachedEnd: hasReachedEnd,
      isLoading: false,
      error: null,
    );
  }

  @override
  List<Object?> get props => [
        items,
        currentParams,
        isLoading,
        isLoadingMore,
        hasReachedEnd,
        error,
        loadMoreError,
      ];
}
