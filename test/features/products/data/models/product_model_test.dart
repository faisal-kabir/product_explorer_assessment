import 'package:flutter_test/flutter_test.dart';
import 'package:product_explorer_assessment/features/products/data/models/product_dimensions_model.dart';
import 'package:product_explorer_assessment/features/products/data/models/product_meta_model.dart';
import 'package:product_explorer_assessment/features/products/data/models/product_model.dart';
import 'package:product_explorer_assessment/features/products/data/models/product_response_model.dart';
import 'package:product_explorer_assessment/features/products/data/models/product_review_model.dart';

void main() {
  group('ProductModel JSON Parsing', () {
    final sampleJson = {
      "id": 11,
      "title": "Annibale Colombo Bed",
      "description": "The Annibale Colombo Bed is a luxurious bed.",
      "category": "furniture",
      "price": 1899.99,
      "discountPercentage": 8.57,
      "rating": 4.77,
      "stock": 88,
      "tags": ["furniture", "beds"],
      "brand": "Annibale Colombo",
      "sku": "FUR-ANN-ANN-011",
      "weight": 10,
      "dimensions": {"width": 28.16, "height": 25.36, "depth": 17.28},
      "warrantyInformation": "1 year warranty",
      "shippingInformation": "Ships in 1 month",
      "availabilityStatus": "In Stock",
      "reviews": [
        {
          "rating": 2,
          "comment": "Would not recommend!",
          "date": "2025-04-30T09:41:02.053Z",
          "reviewerName": "Christopher West",
          "reviewerEmail": "christopher.west@x.dummyjson.com",
        },
      ],
      "returnPolicy": "No return policy",
      "minimumOrderQuantity": 1,
      "meta": {
        "createdAt": "2026-05-31T06:08:47.181Z",
        "updatedAt": "2026-06-02T19:49:21.474Z",
        "barcode": "3610757456581",
        "qrCode": "https://cdn.dummyjson.com/public/qr-code.png",
      },
      "images": [
        "https://cdn.dummyjson.com/product-images/furniture/annibale-colombo-bed/1.webp",
      ],
      "thumbnail": "https://cdn.dummyjson.com/product-images/furniture/annibale-colombo-bed/thumbnail.webp",
      "customField": "extra_value",
    };

    test('should correctly parse complete product JSON from API', () {
      final model = ProductModel.fromJson(sampleJson);

      expect(model.id, 11);
      expect(model.title, "Annibale Colombo Bed");
      expect(model.price, 1899.99);
      expect(model.discountPercentage, 8.57);
      expect(model.rating, 4.77);
      expect(model.stock, 88);
      expect(model.brand, "Annibale Colombo");
      expect(model.tags, ["furniture", "beds"]);
      expect(model.weight, 10.0);
      expect(model.dimensions, isA<ProductDimensionsModel>());
      expect(model.dimensions?.width, 28.16);
      expect(model.reviews.length, 1);
      expect(model.reviews.first, isA<ProductReviewModel>());
      expect(model.reviews.first.reviewerName, "Christopher West");
      expect(model.meta, isA<ProductMetaModel>());
      expect(model.meta?.barcode, "3610757456581");
      expect(
        model.meta?.qrCode,
        "https://cdn.dummyjson.com/public/qr-code.png",
      );
      expect(model.images.length, 1);
      expect(model.thumbnail, contains("thumbnail.webp"));
      expect(model.rawExtraData['customField'], "extra_value");
      expect(model.hasDiscount, true);
      expect(model.isInStock, true);
    });

    test('should safely handle missing optional fields and null values', () {
      final minimalJson = {
        "id": 16,
        "title": "Apple",
        "description": "Fresh and crisp apples.",
        "category": "groceries",
        "price": 2,
        "discountPercentage": 0,
        "rating": 4,
        "stock": 0,
      };

      final model = ProductModel.fromJson(minimalJson);

      expect(model.id, 16);
      expect(model.title, "Apple");
      expect(model.brand, isNull);
      expect(model.sku, isNull);
      expect(model.weight, isNull);
      expect(model.dimensions, isNull);
      expect(model.reviews, isEmpty);
      expect(model.meta, isNull);
      expect(model.images, isEmpty);
      expect(model.thumbnail, isEmpty);
      expect(model.hasDiscount, false);
      expect(model.isInStock, false);
      expect(model.effectiveAvailabilityStatus, "Out of Stock");
    });

    test(
      'should parse ProductResponseModel envelope with pagination metadata',
      () {
        final envelopeJson = {
          "products": [sampleJson],
          "total": 194,
          "skip": 10,
          "limit": 20,
        };

        final responseModel = ProductResponseModel.fromJson(envelopeJson);

        expect(responseModel.total, 194);
        expect(responseModel.skip, 10);
        expect(responseModel.limit, 20);
        expect(responseModel.products.length, 1);
        expect(responseModel.hasMore, true);
      },
    );
  });
}
