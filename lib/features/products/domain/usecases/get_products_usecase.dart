import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product_response_entity.dart';
import '../repositories/product_repository.dart';

@lazySingleton
class GetProductsUseCase
    implements UseCase<ProductResponseEntity, GetProductsParams> {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  @override
  Future<Either<Failure, ProductResponseEntity>> call(
    GetProductsParams params,
  ) async {
    return await repository.getProducts(limit: params.limit, skip: params.skip);
  }
}

class GetProductsParams extends Equatable {
  final int limit;
  final int skip;

  const GetProductsParams({this.limit = 10, this.skip = 0});

  @override
  List<Object?> get props => [limit, skip];
}
