import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;
  final double? size;

  const LoadingWidget({
    super.key,
    this.message,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 40,
            height: size ?? 40,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primary,
              ),
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
