import 'package:equatable/equatable.dart';

import '../../domain/entities/product_entity.dart';

enum ProductStatus {
  initial,
  loading,
  success,
  error,
  paginationLoading,
  paginationError,
  refreshing,
}

class ProductState extends Equatable {
  final ProductStatus status;
  final List<ProductEntity> products;
  final int total;
  final int skip;
  final bool hasReachedMax;
  final String? errorMessage;
  final String? paginationErrorMessage;

  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.total = 0,
    this.skip = 0,
    this.hasReachedMax = false,
    this.errorMessage,
    this.paginationErrorMessage,
  });

  bool get isInitial => status == ProductStatus.initial;
  bool get isLoading => status == ProductStatus.loading;
  bool get isSuccess => status == ProductStatus.success;
  bool get isError => status == ProductStatus.error;
  bool get isPaginationLoading => status == ProductStatus.paginationLoading;
  bool get isPaginationError => status == ProductStatus.paginationError;
  bool get isRefreshing => status == ProductStatus.refreshing;
  bool get isEmpty => isSuccess && products.isEmpty;

  ProductState copyWith({
    ProductStatus? status,
    List<ProductEntity>? products,
    int? total,
    int? skip,
    bool? hasReachedMax,
    String? errorMessage,
    String? paginationErrorMessage,
    bool clearErrorMessage = false,
    bool clearPaginationErrorMessage = false,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      total: total ?? this.total,
      skip: skip ?? this.skip,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      paginationErrorMessage: clearPaginationErrorMessage
          ? null
          : (paginationErrorMessage ?? this.paginationErrorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    total,
    skip,
    hasReachedMax,
    errorMessage,
    paginationErrorMessage,
  ];
}
