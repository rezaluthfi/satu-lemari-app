// File: lib/features/notification/presentation/widgets/notification_shimmer.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Widget shimmer yang ditampilkan saat daftar notifikasi sedang dimuat.
class NotificationShimmer extends StatelessWidget {
  const NotificationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // Shimmer.fromColors memberikan efek kilauan yang bergerak
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 8, // Tampilkan 8 item placeholder
        separatorBuilder: (context, index) => const SizedBox(height: 1),
        itemBuilder: (context, index) {
          return const _ShimmerNotificationCard();
        },
      ),
    );
  }
}

/// Representasi satu kartu notifikasi dalam keadaan shimmer.
class _ShimmerNotificationCard extends StatelessWidget {
  const _ShimmerNotificationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white, // Warna dasar untuk kartu
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder untuk ikon
            _ShimmerContainer(width: 48, height: 48, borderRadius: 12),
            SizedBox(width: 12),
            // Placeholder untuk teks
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Placeholder untuk Judul dan Timestamp
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ShimmerContainer(height: 16, width: 150),
                      _ShimmerContainer(height: 12, width: 50),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Placeholder untuk pesan notifikasi
                  _ShimmerContainer(height: 14),
                  SizedBox(height: 6),
                  _ShimmerContainer(height: 14, width: 200),
                ],
              ),
            ),
            SizedBox(width: 8),
            // Placeholder untuk tombol close
            _ShimmerContainer(width: 24, height: 24, borderRadius: 12),
          ],
        ),
      ),
    );
  }
}

/// Widget helper untuk membuat container placeholder dengan border radius.
class _ShimmerContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const _ShimmerContainer({
    this.width,
    this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        // Warna ini akan ditimpa oleh efek Shimmer.fromColors
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
