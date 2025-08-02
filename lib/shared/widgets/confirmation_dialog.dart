import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final Widget? icon;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.confirmText,
    required this.onConfirm,
    this.cancelText = 'Batal',
    this.onCancel,
    this.isDestructive = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        content,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            cancelText,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: TextButton.styleFrom(
            foregroundColor: isDestructive ? Colors.white : AppColors.primary,
            backgroundColor: isDestructive
                ? AppColors.error
                : AppColors.primary.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            confirmText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Utility method untuk menampilkan dialog konfirmasi standar
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required VoidCallback onConfirm,
    String cancelText = 'Batal',
    VoidCallback? onCancel,
    bool isDestructive = false,
    Widget? icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        onConfirm: onConfirm,
        cancelText: cancelText,
        onCancel: onCancel,
        isDestructive: isDestructive,
        icon: icon,
      ),
    );
  }

  /// Utility method untuk dialog delete yang konsisten
  static Future<bool?> showDeleteConfirmation({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
    Widget? icon,
  }) {
    return show(
      context: context,
      title: title,
      content: content,
      confirmText: 'Hapus',
      onConfirm: onConfirm,
      isDestructive: true,
      icon: icon ??
          const Icon(Icons.delete_outline, color: AppColors.error, size: 24),
    );
  }

  /// Utility method untuk dialog logout yang konsisten
  static Future<bool?> showLogoutConfirmation({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) {
    return show(
      context: context,
      title: 'Logout',
      content: 'Apakah Anda yakin ingin keluar?',
      confirmText: 'Logout',
      onConfirm: onConfirm,
      isDestructive: false,
      icon: const Icon(Icons.logout, color: AppColors.primary, size: 24),
    );
  }
}
