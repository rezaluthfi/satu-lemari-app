import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/core/di/injection.dart';
import 'package:satulemari/features/item_detail/domain/entities/item_detail.dart';
import 'package:satulemari/features/item_detail/presentation/pages/item_detail_page.dart';
import 'package:satulemari/features/order/domain/entities/order_detail.dart';
import 'package:satulemari/features/order/presentation/bloc/order_detail_bloc.dart';
import 'package:satulemari/features/history/presentation/widgets/request_detail_shimmer.dart';
import 'package:satulemari/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:satulemari/shared/widgets/confirmation_dialog.dart';
import 'package:satulemari/shared/widgets/custom_button.dart';
import 'package:satulemari/features/order/presentation/utils/status_helper.dart';

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
        body: BlocListener<OrderDetailBloc, OrderDetailState>(
          listener: (context, state) {
            if (state is OrderCancelSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pesanan berhasil dibatalkan.'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
            if (state is OrderCancelFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: BlocBuilder<OrderDetailBloc, OrderDetailState>(
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
                // Kirim kedua data (detail order dan detail item) ke method build
                return _buildContent(context, state.detail, state.itemDetail);
              }
              return const Center(
                  child: Text('Terjadi kesalahan tidak diketahui.'));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, OrderDetail detail, ItemDetail? itemDetail) {
    final bool canCancel = detail.status.toLowerCase() == 'awaiting_payment';

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
          // Tampilkan item card hanya jika detail item sudah berhasil di-load
          if (itemDetail != null) ...[
            _buildItemCard(context, itemDetail),
            const SizedBox(height: 24),
          ],
          _buildPaymentDetailsCard(context, detail),
          const SizedBox(height: 24),
          _buildStatusCard(context, detail),
          const SizedBox(height: 24),
          if (canCancel)
            CustomButton(
              text: 'Batalkan Pesanan',
              onPressed: () {
                ConfirmationDialog.show(
                  context: context,
                  title: 'Batalkan Pesanan?',
                  content:
                      'Apakah Anda yakin ingin membatalkan pesanan ini? Tindakan ini tidak dapat diurungkan.',
                  confirmText: 'Ya, Batalkan',
                  onConfirm: () {
                    context
                        .read<OrderDetailBloc>()
                        .add(CancelOrderButtonPressed(detail.id));
                  },
                );
              },
              type: ButtonType.outline,
              borderColor: AppColors.error,
              textColor: AppColors.error,
              width: double.infinity,
            ),
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
              Text(
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

  Widget _buildItemCard(BuildContext context, ItemDetail item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Barang Dipesan'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: AppColors.divider.withOpacity(0.3), width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
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
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CachedNetworkImage(
                          imageUrl:
                              item.images.isNotEmpty ? item.images.first : '',
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: AppColors.surfaceVariant),
                          errorWidget: (context, url, error) => const Icon(
                              Icons.inventory_2_outlined,
                              color: AppColors.textHint,
                              size: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            children: [
                              Text(
                                'Lihat detail barang',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios_rounded,
                                  size: 12, color: AppColors.primary),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentDetailsCard(BuildContext context, OrderDetail detail) {
    String formattedDate = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID')
        .format(detail.createdAt.toLocal());

    String getFormattedShippingMethod(String rawMethod) {
      switch (rawMethod) {
        case 'direct_cod':
          return 'Diantar Penjual (COD)';
        case 'app_agent':
          return 'Agen Aplikasi';
        case 'pickup_warehouse':
          return 'Ambil Sendiri (Pickup)';
        default:
          return rawMethod;
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
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
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
    final statusInfo = StatusInfo.fromStatus(detail.status);
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
