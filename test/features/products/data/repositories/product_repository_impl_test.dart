import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:product_explorer_assessment/core/error/exceptions.dart';
import 'package:product_explorer_assessment/core/error/failures.dart';
import 'package:product_explorer_assessment/features/products/data/datasources/product_remote_data_source.dart';
import 'package:product_explorer_assessment/features/products/data/models/product_response_model.dart';
import 'package:product_explorer_assessment/features/products/data/repositories/product_repository_impl.dart';

class MockProductRemoteDataSource extends Mock
    implements ProductRemoteDataSource {}

void main() {
  late ProductRepositoryImpl repository;
  late MockProductRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockProductRemoteDataSource();
    repository = ProductRepositoryImpl(mockRemoteDataSource);
  });

  const tLimit = 10;
  const tSkip = 0;
  const tResponse = ProductResponseModel(
    products: [],
    total: 100,
    skip: 0,
    limit: 10,
  );

  group('getProducts', () {
    test(
      'should return Right(ProductResponseModel) when remote call succeeds',
      () async {
        when(() => mockRemoteDataSource.getProducts(limit: tLimit, skip: tSkip))
            .thenAnswer((_) async => tResponse);

        final result = await repository.getProducts(limit: tLimit, skip: tSkip);

        expect(result, const Right(tResponse));
        verify(
          () => mockRemoteDataSource.getProducts(limit: tLimit, skip: tSkip),
        ).called(1);
      },
    );

    test(
      'should return Left(NetworkFailure) when NetworkException is thrown',
      () async {
        when(() => mockRemoteDataSource.getProducts(limit: tLimit, skip: tSkip))
            .thenThrow(const NetworkException(message: 'Connection timed out'));

        final result = await repository.getProducts(limit: tLimit, skip: tSkip);

        expect(result, const Left(NetworkFailure('Connection timed out')));
        verify(
          () => mockRemoteDataSource.getProducts(limit: tLimit, skip: tSkip),
        ).called(1);
      },
    );

    test(
      'should return Left(ServerFailure) when ServerException is thrown',
      () async {
        when(() => mockRemoteDataSource.getProducts(limit: tLimit, skip: tSkip))
            .thenThrow(const ServerException(message: 'Internal server error'));

        final result = await repository.getProducts(limit: tLimit, skip: tSkip);

        expect(result, const Left(ServerFailure('Internal server error')));
        verify(
          () => mockRemoteDataSource.getProducts(limit: tLimit, skip: tSkip),
        ).called(1);
      },
    );
  });
}
