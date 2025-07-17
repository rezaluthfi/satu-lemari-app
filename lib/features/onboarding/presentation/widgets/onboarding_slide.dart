import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class OnboardingSlideData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingSlideData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class OnboardingSlide extends StatelessWidget {
  final OnboardingSlideData data;
  final bool isActive;

  const OnboardingSlide({
    super.key,
    required this.data,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with animation
          AnimatedScale(
            scale: isActive ? 1.0 : 0.8,
            duration: const Duration(milliseconds: 300),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: data.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: data.color.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                data.icon,
                size: 60,
                color: data.color,
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Title
          AnimatedOpacity(
            opacity: isActive ? 1.0 : 0.7,
            duration: const Duration(milliseconds: 300),
            child: Text(
              data.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Description
          AnimatedOpacity(
            opacity: isActive ? 1.0 : 0.7,
            duration: const Duration(milliseconds: 300),
            child: Text(
              data.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
