import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/core/di/injection.dart';
import 'package:satulemari/features/order/domain/entities/order_detail.dart';
import 'package:satulemari/features/order/presentation/bloc/order_detail_bloc.dart';
import 'package:satulemari/features/history/presentation/widgets/request_detail_shimmer.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orderId = ModalRoute.of(context)!.settings.arguments as String;

    return BlocProvider(
      create: (context) =>
          sl<OrderDetailBloc>()..add(FetchOrderDetail(orderId)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Detail Pesanan'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocBuilder<OrderDetailBloc, OrderDetailState>(
          builder: (context, state) {
            if (state is OrderDetailLoading || state is OrderDetailInitial) {
              return const RequestDetailShimmer();
            }
            if (state is OrderDetailError) {
              return _buildErrorState(state.message);
            }
            if (state is OrderDetailNotFound) {
              return _buildErrorState("Pesanan tidak ditemukan.");
            }
            if (state is OrderDetailLoaded) {
              return _buildContent(context, state.detail);
            }
            return const Center(
                child: Text('Terjadi kesalahan tidak diketahui.'));
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, OrderDetail detail) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (detail.payment.qrisPayload != null &&
              detail.status.toLowerCase() == 'awaiting_payment') ...[
            _buildQrisSection(context, detail),
            const SizedBox(height: 24),
          ],
          // Item card sekarang opsional di detail order, jadi kita hilangkan
          _buildPaymentDetailsCard(context, detail),
          const SizedBox(height: 24),
          _buildStatusCard(context, detail),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildQrisSection(BuildContext context, OrderDetail detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Lakukan Pembayaran'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.warning),
          ),
          child: Column(
            children: [
              const Text(
                'Pindai QR Code di bawah ini untuk menyelesaikan pembayaran Anda',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              Center(
                child: QrImageView(
                  data: detail.payment.qrisPayload!,
                  version: QrVersions.auto,
                  size: 220.0,
                  gapless: false,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer_outlined,
                      color: AppColors.error, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Bayar sebelum: ${DateFormat('dd MMM yyyy, HH:mm').format(detail.expiresAt.toLocal())}',
                    style: const TextStyle(
                        color: AppColors.error, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentDetailsCard(BuildContext context, OrderDetail detail) {
    String formattedDate = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID')
        .format(detail.createdAt.toLocal());

    // Helper function untuk mengubah nama metode pengiriman
    String getFormattedShippingMethod(String rawMethod) {
      switch (rawMethod) {
        case 'direct_cod':
          return 'Diantar Penjual (COD)';
        case 'app_agent':
          return 'Agen Aplikasi';
        case 'pickup_warehouse':
          return 'Ambil Sendiri (Pickup)';
        default:
          return rawMethod; // Fallback jika ada metode baru
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Rincian Pesanan'),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: AppColors.divider.withOpacity(0.3), width: 1),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildInfoRow(
                  icon: Icons.receipt_long_outlined,
                  label: 'ID Pesanan',
                  value: detail.id),
              _buildDivider(),
              _buildInfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Tanggal Pesanan',
                  value: formattedDate),
              _buildDivider(),
              // Gunakan helper function di sini
              _buildInfoRow(
                  icon: Icons.local_shipping_outlined,
                  label: 'Metode Pengiriman',
                  value: getFormattedShippingMethod(detail.shippingMethod)),
              _buildDivider(),
              _buildInfoRow(
                  icon: Icons.payment_outlined,
                  label: 'Metode Pembayaran',
                  value: detail.payment.method.toUpperCase()),
              if (detail.notes != null && detail.notes!.isNotEmpty) ...[
                _buildDivider(),
                _buildInfoRow(
                    icon: Icons.notes_rounded,
                    label: 'Catatan',
                    value: detail.notes!),
              ],
              const SizedBox(height: 20),
              _buildCostSummary(detail),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildCostSummary(OrderDetail detail) {
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Harga Barang',
                  style: TextStyle(color: AppColors.textSecondary)),
              Text(currencyFormat.format(detail.itemPrice),
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ongkos Kirim',
                  style: TextStyle(color: AppColors.textSecondary)),
              Text(currencyFormat.format(detail.shippingFee),
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary)),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Pembayaran',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                currencyFormat.format(detail.totalAmount),
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, OrderDetail detail) {
    final statusInfo = _getStatusInfo(detail.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Status Pesanan'),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: statusInfo.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: statusInfo.color.withOpacity(0.3), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusInfo.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Icon(statusInfo.icon, color: statusInfo.color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusInfo.title,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: statusInfo.color),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusInfo.subtitle,
                        style: TextStyle(
                            fontSize: 14,
                            color: statusInfo.color.withOpacity(0.8),
                            height: 1.4),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: AppColors.divider.withOpacity(0.2),
    );
  }

  StatusInfo _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return StatusInfo(
          icon: Icons.check_circle_rounded,
          color: AppColors.success,
          title: 'Pembayaran Berhasil',
          subtitle: 'Pesanan Anda sedang disiapkan oleh penjual.',
          backgroundColor: AppColors.success.withOpacity(0.05),
        );
      case 'expired':
        return StatusInfo(
          icon: Icons.cancel_rounded,
          color: AppColors.error,
          title: 'Pesanan Dibatalkan',
          subtitle: 'Waktu pembayaran telah habis.',
          backgroundColor: AppColors.error.withOpacity(0.05),
        );
      case 'awaiting_payment':
        return StatusInfo(
          icon: Icons.schedule_rounded,
          color: AppColors.warning,
          title: 'Menunggu Pembayaran',
          subtitle: 'Selesaikan pembayaran sebelum waktu habis.',
          backgroundColor: AppColors.warning.withOpacity(0.05),
        );
      default:
        return StatusInfo(
          icon: Icons.help_outline_rounded,
          color: AppColors.textSecondary,
          title: 'Status Tidak Dikenal',
          subtitle: 'Status pesanan: ${status.capitalize()}',
          backgroundColor: AppColors.surfaceVariant,
        );
    }
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 64),
            const SizedBox(height: 16),
            const Text('Oops, Terjadi Kesalahan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class StatusInfo {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Color backgroundColor;

  StatusInfo({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
  });
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).replaceAll('_', ' ')}";
  }
}
