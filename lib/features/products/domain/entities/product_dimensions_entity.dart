import 'package:equatable/equatable.dart';

class ProductDimensionsEntity extends Equatable {
  final double width;
  final double height;
  final double depth;

  const ProductDimensionsEntity({
    required this.width,
    required this.height,
    required this.depth,
  });

  @override
  List<Object?> get props => [width, height, depth];
}
