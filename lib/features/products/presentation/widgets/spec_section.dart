import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/product_entity.dart';

class SpecSection extends StatelessWidget {
  final ProductEntity product;

  const SpecSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick policy / highlights cards
        _buildHighlightCards(),
        const SizedBox(height: 24),

        // Product Specifications
        const Text(
          'Specifications',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildSpecsCard(),
        const SizedBox(height: 24),

        // Shipping & Warranty Section
        const Text(
          'Shipping & Policies',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildPoliciesCard(),
        const SizedBox(height: 24),

        // Meta Information & QR Code
        if (product.meta != null) ...[
          const Text(
            'Product Metadata',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildMetaCard(),
          const SizedBox(height: 24),
        ],

        // Additional information (if any extra unmapped fields exist)
        if (product.rawExtraData.isNotEmpty) ...[
          _buildAdditionalDataTile(),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildHighlightCards() {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _highlightBox(
              icon: Icons.local_shipping_outlined,
              title: 'Shipping',
              subtitle: product.shippingInformation ?? 'Standard',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _highlightBox(
              icon: Icons.verified_user_outlined,
              title: 'Warranty',
              subtitle: product.warrantyInformation ?? 'None',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _highlightBox(
              icon: Icons.replay_circle_filled_outlined,
              title: 'Return',
              subtitle: product.returnPolicy ?? 'Standard',
            ),
          ),
        ],
      ),
    );
  }

  Widget _highlightBox({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsCard() {
    final rows = <MapEntry<String, String>>[];

    if (product.brand != null && product.brand!.isNotEmpty) {
      rows.add(MapEntry('Brand', product.brand!));
    }
    if (product.category.isNotEmpty) {
      rows.add(MapEntry('Category', product.category));
    }
    if (product.sku != null && product.sku!.isNotEmpty) {
      rows.add(MapEntry('SKU', product.sku!));
    }
    if (product.weight != null) {
      rows.add(MapEntry('Weight', '${product.weight} kg'));
    }
    if (product.dimensions != null) {
      final dim = product.dimensions!;
      rows.add(
        MapEntry(
          'Dimensions (W × H × D)',
          '${dim.width} × ${dim.height} × ${dim.depth} cm',
        ),
      );
    }
    if (product.minimumOrderQuantity != null) {
      rows.add(
        MapEntry('Min Order Quantity', '${product.minimumOrderQuantity} units'),
      );
    }
    rows.add(MapEntry('Stock Available', '${product.stock} items'));
    rows.add(MapEntry('Availability', product.effectiveAvailabilityStatus));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    rows[i].key,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textLight,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      rows[i].value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (i < rows.length - 1)
              const Divider(height: 1, color: AppColors.cardBorder),
          ],
        ],
      ),
    );
  }

  Widget _buildPoliciesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        children: [
          _policyRow(
            icon: Icons.shield_outlined,
            title: 'Warranty Information',
            content: product.warrantyInformation ?? 'No warranty information',
          ),
          const Divider(height: 24, color: AppColors.cardBorder),
          _policyRow(
            icon: Icons.flight_takeoff_rounded,
            title: 'Shipping Information',
            content: product.shippingInformation ?? 'Standard delivery',
          ),
          const Divider(height: 24, color: AppColors.cardBorder),
          _policyRow(
            icon: Icons.assignment_return_outlined,
            title: 'Return Policy',
            content: product.returnPolicy ?? 'No return policy provided',
          ),
        ],
      ),
    );
  }

  Widget _policyRow({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetaCard() {
    final meta = product.meta!;
    final createdStr = meta.createdAt != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(meta.createdAt!)
        : 'N/A';
    final updatedStr = meta.updatedAt != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(meta.updatedAt!)
        : 'N/A';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (meta.barcode.isNotEmpty) ...[
            _metaItem('Barcode', meta.barcode),
            const SizedBox(height: 10),
          ],
          _metaItem('Created At', createdStr),
          const SizedBox(height: 10),
          _metaItem('Updated At', updatedStr),
          if (meta.qrCode.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'QR Code',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: CachedNetworkImage(
                  imageUrl: meta.qrCode,
                  width: 110,
                  height: 110,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const SizedBox(
                    width: 110,
                    height: 110,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => const SizedBox(
                    width: 110,
                    height: 110,
                    child: Center(
                      child: Icon(
                        Icons.qr_code_2_rounded,
                        size: 48,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metaItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textLight),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalDataTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: ExpansionTile(
        title: const Text(
          'Additional Information',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        shape: const Border(),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: product.rawExtraData.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.key}: ',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textLight,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${entry.value}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
