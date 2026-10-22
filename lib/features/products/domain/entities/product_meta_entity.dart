import 'package:equatable/equatable.dart';

class ProductMetaEntity extends Equatable {
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String barcode;
  final String qrCode;

  const ProductMetaEntity({
    this.createdAt,
    this.updatedAt,
    required this.barcode,
    required this.qrCode,
  });

  @override
  List<Object?> get props => [createdAt, updatedAt, barcode, qrCode];
}
