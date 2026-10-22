import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../models/product_response_model.dart';

abstract class ProductRemoteDataSource {
  Future<ProductResponseModel> getProducts({
    required int limit,
    required int skip,
  });
}

@LazySingleton(as: ProductRemoteDataSource)
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;

  ProductRemoteDataSourceImpl(this.dio);

  @override
  Future<ProductResponseModel> getProducts({
    required int limit,
    required int skip,
  }) async {
    try {
      final response = await dio.get(
        '/products',
        queryParameters: {'limit': limit, 'skip': skip},
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return ProductResponseModel.fromJson(
            response.data as Map<String, dynamic>,
          );
        } else {
          throw const ParsingException(
            message: 'Invalid response format received from products API',
          );
        }
      } else {
        throw ServerException(
          message: 'Failed to fetch products: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException(
          message: e.message ?? 'Network connection timed out. Please check your internet connection.',
        );
      }
      throw ServerException(
        message:
            e.response?.statusMessage ??
            e.message ??
            'An unexpected server error occurred.',
        statusCode: e.response?.statusCode,
      );
    } on ParsingException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
