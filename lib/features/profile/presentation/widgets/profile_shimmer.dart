import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:satulemari/core/constants/app_colors.dart';

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceVariant,
      highlightColor: AppColors.surface,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Shimmer
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: SafeArea(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 20), // Space for edit button
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 3,
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildShimmerContainer(width: 180, height: 24),
                        const SizedBox(height: 4),
                        _buildShimmerContainer(width: 100, height: 16),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 4),
                            _buildShimmerContainer(width: 120, height: 14),
                          ],
                        ),
                      ],
                    ),
                    // Edit Button Shimmer
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 6),
                            _buildShimmerContainer(width: 50, height: 14),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Main Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Description Card Shimmer
                  _buildShimmerCard(height: 80),
                  const SizedBox(height: 16),
                  // Stats Section Shimmer
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerContainer(width: 150, height: 18),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(
                          3,
                          (_) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: _buildShimmerCard(height: 100),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Donation Quota Card Shimmer
                  _buildShimmerCard(height: 150),
                  const SizedBox(height: 16),
                  // Contact Card Shimmer
                  _buildShimmerCard(height: 200),
                  const SizedBox(height: 16),
                  // Location Card Shimmer
                  _buildShimmerCard(height: 150),
                  const SizedBox(height: 16),
                  // Action Section Shimmer
                  _buildShimmerCard(height: 150),
                  const SizedBox(height: 24),
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

  Widget _buildShimmerCard({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
    );
  }
}
