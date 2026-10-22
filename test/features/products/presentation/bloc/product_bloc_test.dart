import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:product_explorer_assessment/core/error/failures.dart';
import 'package:product_explorer_assessment/features/products/domain/entities/product_entity.dart';
import 'package:product_explorer_assessment/features/products/domain/entities/product_response_entity.dart';
import 'package:product_explorer_assessment/features/products/domain/usecases/get_products_usecase.dart';
import 'package:product_explorer_assessment/features/products/presentation/bloc/product_bloc.dart';
import 'package:product_explorer_assessment/features/products/presentation/bloc/product_event.dart';
import 'package:product_explorer_assessment/features/products/presentation/bloc/product_state.dart';

class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}

void main() {
  late ProductBloc bloc;
  late MockGetProductsUseCase mockGetProductsUseCase;

  setUpAll(() {
    registerFallbackValue(const GetProductsParams());
  });

  setUp(() {
    mockGetProductsUseCase = MockGetProductsUseCase();
    bloc = ProductBloc(getProductsUseCase: mockGetProductsUseCase);
  });

  tearDown(() {
    bloc.close();
  });

  const tProduct1 = ProductEntity(
    id: 1,
    title: 'Product 1',
    description: 'Description 1',
    category: 'electronics',
    price: 100.0,
    discountPercentage: 10.0,
    rating: 4.5,
    stock: 20,
    tags: ['tag1'],
    reviews: [],
    images: ['https://example.com/1.png'],
    thumbnail: 'https://example.com/1.png',
  );

  const tProduct2 = ProductEntity(
    id: 2,
    title: 'Product 2',
    description: 'Description 2',
    category: 'electronics',
    price: 200.0,
    discountPercentage: 15.0,
    rating: 4.8,
    stock: 5,
    tags: ['tag2'],
    reviews: [],
    images: ['https://example.com/2.png'],
    thumbnail: 'https://example.com/2.png',
  );

  const tInitialResponse = ProductResponseEntity(
    products: [tProduct1],
    total: 2,
    skip: 0,
    limit: 10,
  );

  const tSecondPageResponse = ProductResponseEntity(
    products: [tProduct2],
    total: 2,
    skip: 1,
    limit: 10,
  );

  group('ProductBloc Initial Fetch', () {
    test('initial state should be ProductState() with initial status', () {
      expect(bloc.state.status, ProductStatus.initial);
      expect(bloc.state.products, isEmpty);
    });

    blocTest<ProductBloc, ProductState>(
      'emits [loading, success] when ProductFetchInitial succeeds',
      build: () {
        when(() => mockGetProductsUseCase(any()))
            .thenAnswer((_) async => const Right(tInitialResponse));
        return bloc;
      },
      act: (bloc) => bloc.add(const ProductFetchInitial()),
      expect: () => [
        const ProductState(status: ProductStatus.loading),
        const ProductState(
          status: ProductStatus.success,
          products: [tProduct1],
          total: 2,
          skip: 1,
          hasReachedMax: true,
        ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [loading, error] when ProductFetchInitial fails',
      build: () {
        when(() => mockGetProductsUseCase(any())).thenAnswer(
          (_) async => const Left(ServerFailure('Failed to connect to server')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const ProductFetchInitial()),
      expect: () => [
        const ProductState(status: ProductStatus.loading),
        const ProductState(
          status: ProductStatus.error,
          errorMessage: 'Failed to connect to server',
        ),
      ],
    );
  });

  group('ProductBloc Pagination', () {
    blocTest<ProductBloc, ProductState>(
      'emits [paginationLoading, success] and appends products on ProductFetchNextPage',
      build: () {
        when(
          () => mockGetProductsUseCase(
            const GetProductsParams(limit: 10, skip: 1),
          ),
        ).thenAnswer((_) async => const Right(tSecondPageResponse));
        return bloc;
      },
      seed: () => const ProductState(
        status: ProductStatus.success,
        products: [tProduct1],
        total: 2,
        skip: 1,
        hasReachedMax: false,
      ),
      act: (bloc) => bloc.add(const ProductFetchNextPage()),
      expect: () => [
        const ProductState(
          status: ProductStatus.paginationLoading,
          products: [tProduct1],
          total: 2,
          skip: 1,
          hasReachedMax: false,
        ),
        const ProductState(
          status: ProductStatus.success,
          products: [tProduct1, tProduct2],
          total: 2,
          skip: 2,
          hasReachedMax: true,
        ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'retains existing products and sets paginationErrorMessage on pagination failure',
      build: () {
        when(
          () => mockGetProductsUseCase(
            const GetProductsParams(limit: 10, skip: 1),
          ),
        ).thenAnswer(
          (_) async => const Left(NetworkFailure('Network timeout')),
        );
        return bloc;
      },
      seed: () => const ProductState(
        status: ProductStatus.success,
        products: [tProduct1],
        total: 2,
        skip: 1,
        hasReachedMax: false,
      ),
      act: (bloc) => bloc.add(const ProductFetchNextPage()),
      expect: () => [
        const ProductState(
          status: ProductStatus.paginationLoading,
          products: [tProduct1],
          total: 2,
          skip: 1,
          hasReachedMax: false,
        ),
        const ProductState(
          status: ProductStatus.paginationError,
          products: [tProduct1],
          total: 2,
          skip: 1,
          hasReachedMax: false,
          paginationErrorMessage: 'Network timeout',
        ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'does not trigger fetch if hasReachedMax is true',
      build: () => bloc,
      seed: () => const ProductState(
        status: ProductStatus.success,
        products: [tProduct1],
        total: 1,
        skip: 1,
        hasReachedMax: true,
      ),
      act: (bloc) => bloc.add(const ProductFetchNextPage()),
      expect: () => [],
    );
  });

  group('ProductBloc Pull-to-refresh', () {
    blocTest<ProductBloc, ProductState>(
      'resets pagination offset and replaces list with refreshed data',
      build: () {
        when(
          () => mockGetProductsUseCase(
            const GetProductsParams(limit: 10, skip: 0),
          ),
        ).thenAnswer(
          (_) async => const Right(
            ProductResponseEntity(
              products: [tProduct2],
              total: 1,
              skip: 0,
              limit: 10,
            ),
          ),
        );
        return bloc;
      },
      seed: () => const ProductState(
        status: ProductStatus.success,
        products: [tProduct1],
        total: 10,
        skip: 5,
        hasReachedMax: false,
      ),
      act: (bloc) => bloc.add(const ProductRefresh()),
      expect: () => [
        const ProductState(
          status: ProductStatus.refreshing,
          products: [tProduct1],
          total: 10,
          skip: 5,
          hasReachedMax: false,
        ),
        const ProductState(
          status: ProductStatus.success,
          products: [tProduct2],
          total: 1,
          skip: 1,
          hasReachedMax: true,
        ),
      ],
    );
  });
}
