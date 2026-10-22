import '../../domain/entities/product_dimensions_entity.dart';

class ProductDimensionsModel extends ProductDimensionsEntity {
  const ProductDimensionsModel({
    required super.width,
    required super.height,
    required super.depth,
  });

  factory ProductDimensionsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ProductDimensionsModel(width: 0.0, height: 0.0, depth: 0.0);
    }
    return ProductDimensionsModel(
      width: (json['width'] as num?)?.toDouble() ?? 0.0,
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
      depth: (json['depth'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'width': width, 'height': height, 'depth': depth};
  }
}
