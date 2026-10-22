import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:product_explorer_assessment/features/products/domain/entities/product_response_entity.dart';
import 'package:product_explorer_assessment/features/products/domain/repositories/product_repository.dart';
import 'package:product_explorer_assessment/features/products/domain/usecases/get_products_usecase.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late GetProductsUseCase useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetProductsUseCase(mockRepository);
  });

  const tLimit = 10;
  const tSkip = 0;
  const tResponse = ProductResponseEntity(
    products: [],
    total: 100,
    skip: 0,
    limit: 10,
  );

  test('should call repository.getProducts with the given limit and skip parameters', () async {
    when(() => mockRepository.getProducts(limit: tLimit, skip: tSkip))
        .thenAnswer((_) async => const Right(tResponse));

    final result = await useCase(
      const GetProductsParams(limit: tLimit, skip: tSkip),
    );

    expect(result, const Right(tResponse));
    verify(() => mockRepository.getProducts(limit: tLimit, skip: tSkip))
        .called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
