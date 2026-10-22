import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'product_event.dart';
import 'product_state.dart';

@injectable
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;
  static const int _pageSize = 10;

  ProductBloc({required this.getProductsUseCase})
    : super(const ProductState()) {
    on<ProductFetchInitial>(_onFetchInitial);
    on<ProductFetchNextPage>(_onFetchNextPage);
    on<ProductRefresh>(_onRefresh);
    on<ProductRetryPagination>(_onRetryPagination);
  }

  Future<void> _onFetchInitial(
    ProductFetchInitial event,
    Emitter<ProductState> emit,
  ) async {
    // Guard against repeated initial calls if already loading
    if (state.isLoading) return;

    emit(
      state.copyWith(
        status: ProductStatus.loading,
        clearErrorMessage: true,
        clearPaginationErrorMessage: true,
      ),
    );

    final result = await getProductsUseCase(
      const GetProductsParams(limit: _pageSize, skip: 0),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProductStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (response) {
        final hasReachedMax =
            response.products.length < _pageSize ||
            (response.products.length >= response.total);

        emit(
          state.copyWith(
            status: ProductStatus.success,
            products: response.products,
            total: response.total,
            skip: response.products.length,
            hasReachedMax: hasReachedMax,
            clearErrorMessage: true,
            clearPaginationErrorMessage: true,
          ),
        );
      },
    );
  }

  Future<void> _onFetchNextPage(
    ProductFetchNextPage event,
    Emitter<ProductState> emit,
  ) async {
    // Guards to prevent concurrent duplicate pagination requests
    if (state.hasReachedMax ||
        state.isPaginationLoading ||
        state.isLoading ||
        state.isRefreshing) {
      return;
    }

    emit(
      state.copyWith(
        status: ProductStatus.paginationLoading,
        clearPaginationErrorMessage: true,
      ),
    );

    final nextSkip = state.skip;
    final result = await getProductsUseCase(
      GetProductsParams(limit: _pageSize, skip: nextSkip),
    );

    result.fold(
      (failure) {
        // Keep existing products visible on pagination error
        emit(
          state.copyWith(
            status: ProductStatus.paginationError,
            paginationErrorMessage: failure.message,
          ),
        );
      },
      (response) {
        // Deduplicate products by id to prevent duplicate keys in UI
        final existingIds = state.products.map((p) => p.id).toSet();
        final newUnique = response.products
            .where((p) => !existingIds.contains(p.id))
            .toList();

        final updatedList = List<ProductEntity>.from(state.products)
          ..addAll(newUnique);
        final newSkip = state.skip + response.products.length;
        final hasReachedMax =
            response.products.isEmpty ||
            response.products.length < _pageSize ||
            newSkip >= response.total;

        emit(
          state.copyWith(
            status: ProductStatus.success,
            products: updatedList,
            total: response.total,
            skip: newSkip,
            hasReachedMax: hasReachedMax,
            clearPaginationErrorMessage: true,
          ),
        );
      },
    );
  }

  Future<void> _onRefresh(
    ProductRefresh event,
    Emitter<ProductState> emit,
  ) async {
    // Prevent starting refresh if already refreshing
    if (state.isRefreshing) return;

    emit(
      state.copyWith(
        status: ProductStatus.refreshing,
        clearErrorMessage: true,
        clearPaginationErrorMessage: true,
      ),
    );

    final result = await getProductsUseCase(
      const GetProductsParams(limit: _pageSize, skip: 0),
    );

    result.fold(
      (failure) {
        // If we already have products, preserve them and switch back to success or error
        if (state.products.isNotEmpty) {
          emit(
            state.copyWith(
              status: ProductStatus.success,
              errorMessage: failure.message,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: ProductStatus.error,
              errorMessage: failure.message,
            ),
          );
        }
      },
      (response) {
        final hasReachedMax =
            response.products.length < _pageSize ||
            (response.products.length >= response.total);

        // Replace existing list with refreshed data
        emit(
          state.copyWith(
            status: ProductStatus.success,
            products: response.products,
            total: response.total,
            skip: response.products.length,
            hasReachedMax: hasReachedMax,
            clearErrorMessage: true,
            clearPaginationErrorMessage: true,
          ),
        );
      },
    );
  }

  void _onRetryPagination(
    ProductRetryPagination event,
    Emitter<ProductState> emit,
  ) {
    add(const ProductFetchNextPage());
  }
}
