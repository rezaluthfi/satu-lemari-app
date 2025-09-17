import 'package:flutter/material.dart';
import 'package:satulemari/core/constants/app_colors.dart';

class StatusInfo {
  final IconData icon;
  final Color color;
  final String label; // Untuk badge singkat di daftar
  final String title; // Untuk judul di halaman detail
  final String subtitle; // Untuk deskripsi di halaman detail
  final Color backgroundColor;

  StatusInfo({
    required this.icon,
    required this.color,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
  });

  // Factory constructor yang menjadi pusat logika
  factory StatusInfo.fromStatus(String status) {
    switch (status.toLowerCase()) {
      case 'awaiting_payment':
        return StatusInfo(
          icon: Icons.schedule_rounded,
          color: AppColors.warning,
          label: 'Menunggu',
          title: 'Menunggu Pembayaran',
          subtitle: 'Selesaikan pembayaran sebelum waktu habis.',
          backgroundColor: AppColors.warning.withOpacity(0.05),
        );
      case 'paid':
        return StatusInfo(
          icon: Icons.check_circle_outline_rounded,
          color: AppColors.success,
          label: 'Dibayar',
          title: 'Pembayaran Berhasil',
          subtitle: 'Pesanan Anda telah dibayar dan sedang diproses.',
          backgroundColor: AppColors.success.withOpacity(0.05),
        );
      case 'processing':
        return StatusInfo(
          icon: Icons.sync_rounded,
          color: AppColors.info,
          label: 'Diproses',
          title: 'Sedang Diproses',
          subtitle: 'Pesanan Anda sedang disiapkan oleh penjual.',
          backgroundColor: AppColors.info.withOpacity(0.05),
        );
      case 'shipped':
        return StatusInfo(
          icon: Icons.local_shipping_outlined,
          color: AppColors.info,
          label: 'Dikirim',
          title: 'Telah Dikirim',
          subtitle: 'Pesanan Anda dalam perjalanan ke lokasi Anda.',
          backgroundColor: AppColors.info.withOpacity(0.05),
        );
      case 'delivered':
        return StatusInfo(
          icon: Icons.inventory_2_outlined,
          color: AppColors.success,
          label: 'Tiba',
          title: 'Telah Tiba',
          subtitle: 'Pesanan Anda telah tiba di tujuan.',
          backgroundColor: AppColors.success.withOpacity(0.05),
        );
      case 'completed':
        return StatusInfo(
          icon: Icons.verified_rounded,
          color: AppColors.success,
          label: 'Selesai',
          title: 'Pesanan Selesai',
          subtitle: 'Transaksi ini telah berhasil diselesaikan.',
          backgroundColor: AppColors.success.withOpacity(0.05),
        );
      case 'cancelled':
        return StatusInfo(
          icon: Icons.cancel_rounded,
          color: AppColors.error,
          label: 'Dibatalkan',
          title: 'Pesanan Dibatalkan',
          subtitle: 'Pesanan ini telah dibatalkan.',
          backgroundColor: AppColors.error.withOpacity(0.05),
        );
      case 'expired':
        return StatusInfo(
          icon: Icons.timer_off_outlined,
          color: AppColors.error,
          label: 'Kedaluwarsa',
          title: 'Pesanan Kedaluwarsa',
          subtitle: 'Waktu pembayaran untuk pesanan ini telah habis.',
          backgroundColor: AppColors.error.withOpacity(0.05),
        );
      default:
        return StatusInfo(
          icon: Icons.help_outline_rounded,
          color: AppColors.textSecondary,
          label: status.capitalize(),
          title: 'Status: ${status.capitalize()}',
          subtitle: 'Status pesanan tidak dikenali.',
          backgroundColor: AppColors.surfaceVariant,
        );
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return split('_')
        .map((word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' ');
  }
}
