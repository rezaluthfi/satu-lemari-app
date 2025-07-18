import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:satulemari/core/constants/app_colors.dart';

class ItemDetailShimmer extends StatelessWidget {
  const ItemDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceVariant,
      highlightColor: AppColors.surface,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder for Image AppBar
            Container(
              height: 350.0,
              color: Colors.white,
            ),
            // Placeholder for Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildShimmerContainer(width: 100, height: 12),
                  const SizedBox(height: 8),
                  _buildShimmerContainer(width: 250, height: 24),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),

                  // Info Section
                  _buildShimmerContainer(width: 80, height: 18),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(4, (_) => _buildShimmerInfoChip()),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),

                  // Description
                  _buildShimmerContainer(width: 120, height: 18),
                  const SizedBox(height: 8),
                  _buildShimmerContainer(width: double.infinity, height: 14),
                  const SizedBox(height: 6),
                  _buildShimmerContainer(width: double.infinity, height: 14),
                  const SizedBox(height: 6),
                  _buildShimmerContainer(width: 200, height: 14),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),

                  // Partner Info
                  _buildShimmerContainer(width: 100, height: 18),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShimmerContainer(width: 150, height: 14),
                          const SizedBox(height: 6),
                          _buildShimmerContainer(width: 100, height: 12),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerContainer(
      {required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildShimmerInfoChip() {
    return Column(
      children: [
        _buildShimmerContainer(width: 50, height: 12),
        const SizedBox(height: 4),
        _buildShimmerContainer(width: 70, height: 28),
      ],
    );
  }
}
