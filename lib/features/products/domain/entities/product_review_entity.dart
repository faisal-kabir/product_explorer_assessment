import 'package:equatable/equatable.dart';

class ProductReviewEntity extends Equatable {
  final double rating;
  final String comment;
  final DateTime? date;
  final String reviewerName;
  final String reviewerEmail;

  const ProductReviewEntity({
    required this.rating,
    required this.comment,
    this.date,
    required this.reviewerName,
    required this.reviewerEmail,
  });

  @override
  List<Object?> get props => [
    rating,
    comment,
    date,
    reviewerName,
    reviewerEmail,
  ];
}
