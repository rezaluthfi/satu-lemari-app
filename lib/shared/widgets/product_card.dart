import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/core/utils/string_extensions.dart';
import 'package:satulemari/features/category_items/domain/entities/item_entity.dart';
import 'package:satulemari/features/home/domain/entities/recommendation.dart';
import 'package:satulemari/features/item_detail/presentation/pages/item_detail_page.dart';
import 'package:satulemari/features/profile/presentation/bloc/profile_bloc.dart';

class ProductCard extends StatelessWidget {
  final Recommendation? recommendation;
  final Item? item;
  final bool isCarousel;

  const ProductCard({
    super.key,
    this.recommendation,
    this.item,
    this.isCarousel = false,
  }) : assert(recommendation != null || item != null);

  @override
  Widget build(BuildContext context) {
    final String itemId = recommendation?.itemId ?? item!.id;
    final String title = recommendation?.title ?? item!.name;
    final String? imageUrl = recommendation?.imageUrl ?? item?.imageUrl;
    final ItemType type = recommendation?.type ?? item!.type;
    final String category = recommendation?.category ?? '';
    final String? size = item?.size;
    final String? condition = item?.condition;
    final int? availableQuantity = item?.availableQuantity;
    final double? price = item?.price;

    final tagColor =
        type == ItemType.donation ? AppColors.donation : AppColors.rental;
    final tagText = type == ItemType.donation ? 'Donasi' : 'Sewa';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              // Menyediakan instance ProfileBloc yang ada ke route baru
              value: BlocProvider.of<ProfileBloc>(context),
              child: const ItemDetailPage(),
            ),
            // Tetap meneruskan itemId melalui settings
            settings: RouteSettings(
              arguments: itemId,
            ),
          ),
        );
        // --- AKHIR PERBAIKAN ---
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: isCarousel ? 200 : null,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    height: isCarousel ? 160 : 200,
                    width: double.infinity,
                    child: (imageUrl != null && imageUrl.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (c, u) => Container(
                                color: AppColors.surfaceVariant,
                                child: const Center(
                                    child: CircularProgressIndicator(
                                        color: AppColors.primary,
                                        strokeWidth: 2))),
                            errorWidget: (c, u, e) => Container(
                                color: AppColors.surfaceVariant,
                                child: const Center(
                                    child: Icon(Icons.broken_image_rounded,
                                        color: AppColors.disabled, size: 32))))
                        : Container(
                            color: AppColors.surfaceVariant,
                            child: const Center(
                                child: Icon(Icons.inventory_2_rounded,
                                    color: AppColors.disabled, size: 32))),
                  ),
                ),
                if (type != ItemType.unknown)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: tagColor,
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(tagText,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
              ],
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (recommendation != null)
                      Text(
                        category.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (recommendation != null) const SizedBox(height: 6),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          height: 1.3),
                    ),
                    const SizedBox(height: 8),
                    if (type == ItemType.rental && price != null && price > 0)
                      Text(
                        NumberFormat.currency(
                                locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
                            .format(price),
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (item != null) ...[
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (size != null) ...[
                              _buildInfoChip(Icons.straighten_rounded, size),
                              const SizedBox(width: 8),
                            ],
                            if (condition != null)
                              _buildInfoChip(Icons.verified_outlined,
                                  condition.toFormattedCondition()),
                          ],
                        ),
                      ),
                      if (availableQuantity != null &&
                          availableQuantity <= 2 &&
                          availableQuantity > 0) ...[
                        const SizedBox(height: 8),
                        const Text('Stok Terbatas!',
                            style: TextStyle(
                                color: AppColors.premium,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ]
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String? text) {
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
