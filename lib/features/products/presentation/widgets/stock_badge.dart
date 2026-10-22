import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class StockBadge extends StatelessWidget {
  final int stock;
  final String? availabilityStatus;

  const StockBadge({super.key, required this.stock, this.availabilityStatus});

  @override
  Widget build(BuildContext context) {
    final Color dotColor;
    final String label;

    if (stock <= 0) {
      dotColor = AppColors.outOfStock;
      label = availabilityStatus?.isNotEmpty == true
          ? availabilityStatus!
          : 'Out of Stock';
    } else if (stock <= 10) {
      dotColor = AppColors.lowStock;
      label = availabilityStatus?.isNotEmpty == true
          ? availabilityStatus!
          : 'Low Stock';
    } else {
      dotColor = AppColors.inStock;
      label = availabilityStatus?.isNotEmpty == true
          ? availabilityStatus!
          : 'In Stock';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: dotColor,
          ),
        ),
      ],
    );
  }
}
