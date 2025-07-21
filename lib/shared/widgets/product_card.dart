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
  final Item item;
  final bool isCarousel;

  const ProductCard({
    super.key,
    required this.item,
    this.isCarousel = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: BlocProvider.of<ProfileBloc>(context),
              child: const ItemDetailPage(),
            ),
            settings: RouteSettings(arguments: item.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: isCarousel ? MainAxisSize.max : MainAxisSize.min,
          children: [
            _ProductImage(imageUrl: item.imageUrl, type: item.type),
            if (isCarousel)
              Expanded(
                child: _CarouselContent(item: item),
              )
            else
              _GridContent(item: item),
          ],
        ),
      ),
    );
  }
}

// Konten untuk Carousel (menggunakan spaceBetween)
class _CarouselContent extends StatelessWidget {
  final Item item;
  const _CarouselContent({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _TopInfo(item: item),
          _BottomInfo(item: item),
        ],
      ),
    );
  }
}

// Konten untuk Grid (menggunakan SizedBox manual)
class _GridContent extends StatelessWidget {
  final Item item;
  const _GridContent({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _TopInfo(item: item),
          const SizedBox(height: 8),
          _BottomInfo(item: item),
        ],
      ),
    );
  }
}

// Info Atas: Kategori dan Judul (Reusable)
class _TopInfo extends StatelessWidget {
  final Item item;
  const _TopInfo({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.categoryName != null && item.categoryName!.isNotEmpty) ...[
          Text(
            item.categoryName!.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 10,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          item.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.3),
        ),
      ],
    );
  }
}

// Info Bawah: Harga, Chip, Stok (Reusable)
class _BottomInfo extends StatelessWidget {
  final Item item;
  const _BottomInfo({required this.item});

  @override
  Widget build(BuildContext context) {
    final bool hasPrice =
        item.type == ItemType.rental && item.price != null && item.price! > 0;

    final bool hasLimitedStock = item.availableQuantity != null &&
        item.availableQuantity! <= 2 &&
        item.availableQuantity! > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===================================
        // PERBAIKAN FINAL
        // Hanya tampilkan jika ada harga. Tidak ada 'else'.
        // ===================================
        if (hasPrice)
          Padding(
            // Tambahkan padding bawah agar jaraknya sama dengan jarak saat harga tidak ada.
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              NumberFormat.currency(
                      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                  .format(item.price),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
          ),

        // Jarak ini hanya akan muncul jika tidak ada harga,
        // menciptakan ruang sebelum chip info.
        if (!hasPrice) const SizedBox(height: 8),

        Row(
          children: [
            if (item.size != null && item.size!.isNotEmpty) ...[
              _buildInfoChip(Icons.straighten_rounded, item.size),
              const SizedBox(width: 6),
            ],
            if (item.condition != null && item.condition!.isNotEmpty)
              Flexible(
                child: _buildInfoChip(Icons.verified_outlined,
                    item.condition!.toFormattedCondition()),
              ),
          ],
        ),

        // ===================================
        // PERBAIKAN FINAL
        // Hanya tampilkan jika stok terbatas. Tidak ada 'else'.
        // ===================================
        if (hasLimitedStock)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text('Stok Terbatas!',
                style: TextStyle(
                    color: AppColors.premium,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String? text) {
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Gambar (Tidak berubah)
class _ProductImage extends StatelessWidget {
  final String? imageUrl;
  final ItemType type;

  const _ProductImage({required this.imageUrl, required this.type});

  @override
  Widget build(BuildContext context) {
    final tagColor =
        type == ItemType.donation ? AppColors.donation : AppColors.rental;
    final tagText = type == ItemType.donation ? 'Donasi' : 'Sewa';

    return AspectRatio(
      aspectRatio: 1.25,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null && imageUrl!.isNotEmpty)
            CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              placeholder: (c, u) => Container(color: AppColors.surfaceVariant),
              errorWidget: (c, u, e) => Container(
                  color: AppColors.surfaceVariant,
                  child: const Center(
                      child: Icon(Icons.broken_image_rounded,
                          color: AppColors.disabled, size: 32))),
            )
          else
            Container(
                color: AppColors.surfaceVariant,
                child: const Center(
                    child: Icon(Icons.inventory_2_rounded,
                        color: AppColors.disabled, size: 32))),
          if (type != ItemType.unknown)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: tagColor, borderRadius: BorderRadius.circular(12)),
                child: Text(tagText,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }
}
