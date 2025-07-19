import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:satulemari/core/constants/app_colors.dart';

class RequestDetailShimmer extends StatelessWidget {
  const RequestDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceVariant,
      highlightColor: AppColors.surface,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildItemCardShimmer(),
            const SizedBox(height: 24),
            _buildRequestCardShimmer(),
            const SizedBox(height: 24),
            _buildPartnerCardShimmer(),
            const SizedBox(height: 24),
            _buildStatusCardShimmer(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCardShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        _buildShimmerContainer(width: 180, height: 20),
        const SizedBox(height: 12),
        // Item card
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.divider.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Item image placeholder
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item name
                      _buildShimmerContainer(
                          width: double.infinity, height: 16),
                      const SizedBox(height: 8),
                      _buildShimmerContainer(width: 150, height: 14),
                      const SizedBox(height: 8),
                      // "Lihat detail barang" text
                      _buildShimmerContainer(width: 120, height: 13),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestCardShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        _buildShimmerContainer(width: 150, height: 20),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.divider.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // First info row (Tanggal Permintaan)
                _buildInfoRowShimmer(),
                const SizedBox(height: 20),
                _buildDividerShimmer(),
                const SizedBox(height: 20),
                // Second info row (could be reason or pickup date)
                _buildInfoRowShimmer(),
                const SizedBox(height: 20),
                _buildDividerShimmer(),
                const SizedBox(height: 20),
                // Third info row (return date for borrowing)
                _buildInfoRowShimmer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPartnerCardShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        _buildShimmerContainer(width: 140, height: 20),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.divider.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Partner name row
                _buildInfoRowShimmer(),
                const SizedBox(height: 20),
                _buildDividerShimmer(),
                const SizedBox(height: 20),
                // Address row
                _buildInfoRowShimmer(),
                const SizedBox(height: 20),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCardShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        _buildShimmerContainer(width: 160, height: 20),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.divider.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Status icon placeholder
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status title
                      _buildShimmerContainer(width: 180, height: 16),
                      const SizedBox(height: 8),
                      // Status subtitle
                      _buildShimmerContainer(
                          width: double.infinity, height: 14),
                      const SizedBox(height: 4),
                      _buildShimmerContainer(width: 200, height: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRowShimmer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon placeholder
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label
              _buildShimmerContainer(width: 120, height: 12),
              const SizedBox(height: 6),
              // Value
              _buildShimmerContainer(width: double.infinity, height: 14),
              const SizedBox(height: 2),
              _buildShimmerContainer(width: 150, height: 14),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDividerShimmer() {
    return Container(
      height: 1,
      width: double.infinity,
      color: Colors.white,
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
}
