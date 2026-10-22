import 'package:equatable/equatable.dart';

import 'product_dimensions_entity.dart';
import 'product_meta_entity.dart';
import 'product_review_entity.dart';

class ProductEntity extends Equatable {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final List<String> tags;
  final String? brand;
  final String? sku;
  final double? weight;
  final ProductDimensionsEntity? dimensions;
  final String? warrantyInformation;
  final String? shippingInformation;
  final String? availabilityStatus;
  final List<ProductReviewEntity> reviews;
  final String? returnPolicy;
  final int? minimumOrderQuantity;
  final ProductMetaEntity? meta;
  final List<String> images;
  final String thumbnail;
  final Map<String, dynamic> rawExtraData;

  const ProductEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.tags,
    this.brand,
    this.sku,
    this.weight,
    this.dimensions,
    this.warrantyInformation,
    this.shippingInformation,
    this.availabilityStatus,
    required this.reviews,
    this.returnPolicy,
    this.minimumOrderQuantity,
    this.meta,
    required this.images,
    required this.thumbnail,
    this.rawExtraData = const {},
  });

  /// Computed original price before discount
  double get originalPrice {
    if (discountPercentage <= 0 || discountPercentage >= 100) {
      return price;
    }
    return price / (1 - (discountPercentage / 100));
  }

  bool get hasDiscount => discountPercentage > 0;

  bool get isInStock => stock > 0;

  bool get isLowStock => stock > 0 && stock <= 10;

  String get effectiveAvailabilityStatus {
    if (availabilityStatus != null && availabilityStatus!.isNotEmpty) {
      return availabilityStatus!;
    }
    if (stock == 0) return 'Out of Stock';
    if (stock <= 10) return 'Low Stock';
    return 'In Stock';
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    category,
    price,
    discountPercentage,
    rating,
    stock,
    tags,
    brand,
    sku,
    weight,
    dimensions,
    warrantyInformation,
    shippingInformation,
    availabilityStatus,
    reviews,
    returnPolicy,
    minimumOrderQuantity,
    meta,
    images,
    thumbnail,
    rawExtraData,
  ];
}
