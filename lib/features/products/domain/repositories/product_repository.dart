import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/product_response_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, ProductResponseEntity>> getProducts({
    required int limit,
    required int skip,
  });
}
