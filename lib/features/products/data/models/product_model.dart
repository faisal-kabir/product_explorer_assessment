import '../../domain/entities/product_entity.dart';
import 'product_dimensions_model.dart';
import 'product_meta_model.dart';
import 'product_review_model.dart';

class ProductModel extends ProductEntity {
  static const Set<String> _knownKeys = {
    'id',
    'title',
    'description',
    'category',
    'price',
    'discountPercentage',
    'rating',
    'stock',
    'tags',
    'brand',
    'sku',
    'weight',
    'dimensions',
    'warrantyInformation',
    'shippingInformation',
    'availabilityStatus',
    'reviews',
    'returnPolicy',
    'minimumOrderQuantity',
    'meta',
    'images',
    'thumbnail',
  };

  const ProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.price,
    required super.discountPercentage,
    required super.rating,
    required super.stock,
    required super.tags,
    super.brand,
    super.sku,
    super.weight,
    super.dimensions,
    super.warrantyInformation,
    super.shippingInformation,
    super.availabilityStatus,
    required super.reviews,
    super.returnPolicy,
    super.minimumOrderQuantity,
    super.meta,
    required super.images,
    required super.thumbnail,
    super.rawExtraData,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Collect any unrepresented fields for "Additional Information"
    final extraData = <String, dynamic>{};
    json.forEach((key, value) {
      if (!_knownKeys.contains(key)) {
        extraData[key] = value;
      }
    });

    final tagsList =
        (json['tags'] as List?)
            ?.map((e) => e?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList() ??
        const <String>[];

    final imagesList =
        (json['images'] as List?)
            ?.map((e) => e?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList() ??
        const <String>[];

    final reviewsList =
        (json['reviews'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map((e) => ProductReviewModel.fromJson(e))
            .toList() ??
        const <ProductReviewModel>[];

    final thumbnail =
        json['thumbnail']?.toString() ??
        (imagesList.isNotEmpty ? imagesList.first : '');

    return ProductModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      tags: tagsList,
      brand: json['brand']?.toString(),
      sku: json['sku']?.toString(),
      weight: (json['weight'] as num?)?.toDouble(),
      dimensions: json['dimensions'] is Map<String, dynamic>
          ? ProductDimensionsModel.fromJson(
              json['dimensions'] as Map<String, dynamic>,
            )
          : null,
      warrantyInformation: json['warrantyInformation']?.toString(),
      shippingInformation: json['shippingInformation']?.toString(),
      availabilityStatus: json['availabilityStatus']?.toString(),
      reviews: reviewsList,
      returnPolicy: json['returnPolicy']?.toString(),
      minimumOrderQuantity: (json['minimumOrderQuantity'] as num?)?.toInt(),
      meta: json['meta'] is Map<String, dynamic>
          ? ProductMetaModel.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
      images: imagesList,
      thumbnail: thumbnail,
      rawExtraData: extraData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'tags': tags,
      'brand': brand,
      'sku': sku,
      'weight': weight,
      'dimensions': dimensions != null
          ? (dimensions as ProductDimensionsModel).toJson()
          : null,
      'warrantyInformation': warrantyInformation,
      'shippingInformation': shippingInformation,
      'availabilityStatus': availabilityStatus,
      'reviews': reviews
          .map((e) => (e as ProductReviewModel).toJson())
          .toList(),
      'returnPolicy': returnPolicy,
      'minimumOrderQuantity': minimumOrderQuantity,
      'meta': meta != null ? (meta as ProductMetaModel).toJson() : null,
      'images': images,
      'thumbnail': thumbnail,
      ...rawExtraData,
    };
  }
}
