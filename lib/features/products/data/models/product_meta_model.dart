import '../../domain/entities/product_meta_entity.dart';

class ProductMetaModel extends ProductMetaEntity {
  const ProductMetaModel({
    super.createdAt,
    super.updatedAt,
    required super.barcode,
    required super.qrCode,
  });

  factory ProductMetaModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ProductMetaModel(barcode: '', qrCode: '');
    }
    return ProductMetaModel(
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      barcode: json['barcode']?.toString() ?? '',
      qrCode: json['qrCode']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'barcode': barcode,
      'qrCode': qrCode,
    };
  }
}
