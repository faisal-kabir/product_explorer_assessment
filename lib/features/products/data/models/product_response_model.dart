import '../../domain/entities/product_response_entity.dart';
import 'product_model.dart';

class ProductResponseModel extends ProductResponseEntity {
  const ProductResponseModel({
    required super.products,
    required super.total,
    required super.skip,
    required super.limit,
  });

  factory ProductResponseModel.fromJson(Map<String, dynamic> json) {
    final productsList =
        (json['products'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map((p) => ProductModel.fromJson(p))
            .toList() ??
        <ProductModel>[];

    return ProductResponseModel(
      products: productsList,
      total: (json['total'] as num?)?.toInt() ?? 0,
      skip: (json['skip'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((p) => (p as ProductModel).toJson()).toList(),
      'total': total,
      'skip': skip,
      'limit': limit,
    };
  }
}
