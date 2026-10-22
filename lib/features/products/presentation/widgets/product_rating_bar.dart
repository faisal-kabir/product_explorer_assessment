import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ProductRatingBar extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double iconSize;
  final double fontSize;
  final bool showReviewsLabel;

  const ProductRatingBar({
    super.key,
    required this.rating,
    this.reviewCount = 0,
    this.iconSize = 14,
    this.fontSize = 12,
    this.showReviewsLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.star_rounded, color: AppColors.star, size: iconSize),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (reviewCount > 0) ...[
          const SizedBox(width: 4),
          Text(
            showReviewsLabel ? '($reviewCount reviews)' : '($reviewCount)',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
              color: AppColors.textLight,
            ),
          ),
        ],
      ],
    );
  }
}
