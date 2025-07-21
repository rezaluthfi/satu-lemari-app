import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/core/di/injection.dart';
import 'package:satulemari/features/history/domain/entities/request_detail.dart';
import 'package:satulemari/features/history/presentation/bloc/request_detail_bloc.dart';
import 'package:satulemari/features/history/presentation/widgets/request_detail_shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestDetailPage extends StatelessWidget {
  const RequestDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final requestId = ModalRoute.of(context)!.settings.arguments as String;

    return BlocProvider(
      create: (context) =>
          sl<RequestDetailBloc>()..add(FetchRequestDetail(requestId)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Detail Permintaan',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            BlocBuilder<RequestDetailBloc, RequestDetailState>(
              builder: (context, state) {
                if (state is RequestDetailLoaded) {
                  if (state.detail.status == 'pending' ||
                      state.detail.status == 'rejected') {
                    return Container(
                      margin: const EdgeInsets.only(right: 16),
                      child: IconButton(
                        onPressed: () => _showDeleteDialog(context, requestId),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        style: IconButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(8),
                        ),
                        tooltip: 'Hapus Permintaan',
                      ),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocListener<RequestDetailBloc, RequestDetailState>(
          listener: (context, state) {
            if (state is RequestDeleteSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Permintaan berhasil dihapus'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
              Navigator.of(context).pop(true);
            }
            if (state is RequestDetailError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }
          },
          child: BlocBuilder<RequestDetailBloc, RequestDetailState>(
            builder: (context, state) {
              if (state is RequestDetailLoading ||
                  state is RequestDetailInitial) {
                return const RequestDetailShimmer();
              }
              if (state is RequestDetailError) {
                return _buildErrorState(state.message);
              }
              if (state is RequestDetailLoaded) {
                return _buildContent(context, state.detail);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String requestId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Permintaan',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus permintaan ini? Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context
                  .read<RequestDetailBloc>()
                  .add(DeleteRequestButtonPressed(requestId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Terjadi kesalahan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, RequestDetail detail) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItemCard(context, detail.item),
          const SizedBox(height: 24),
          _buildRequestCard(context, detail),
          const SizedBox(height: 24),
          _buildPartnerCard(context, detail.partner),
          const SizedBox(height: 24),
          _buildStatusCard(context, detail),
          const SizedBox(height: 20),
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

  Widget _buildItemCard(BuildContext context, ItemInRequest item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Barang yang Diajukan'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.divider.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/item-detail',
                    arguments: item.id);
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
                          imageUrl: item.imageUrl ?? '',
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.surfaceVariant,
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              color: AppColors.textHint,
                              size: 24,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.surfaceVariant,
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              color: AppColors.textHint,
                              size: 24,
                            ),
                          ),
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
                              color: AppColors.textPrimary,
                            ),
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
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 12,
                                color: AppColors.primary,
                              ),
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

  Widget _buildRequestCard(BuildContext context, RequestDetail detail) {
    final bool isDonation = detail.type == 'donation';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Detail Permintaan'),
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
                _buildInfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Tanggal Permintaan',
                  value: DateFormat('dd MMMM yyyy, HH:mm')
                      .format(detail.createdAt),
                ),
                if (isDonation &&
                    detail.reason != null &&
                    detail.reason!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildDivider(),
                  const SizedBox(height: 20),
                  _buildInfoRow(
                    icon: Icons.notes_rounded,
                    label: 'Alasan Permintaan',
                    value: detail.reason!,
                  ),
                ],
                if (!isDonation) ...[
                  const SizedBox(height: 20),
                  _buildDivider(),
                  const SizedBox(height: 20),
                  _buildInfoRow(
                    icon: Icons.event_available_rounded,
                    label: 'Tanggal Ambil',
                    value: detail.pickupDate != null
                        ? DateFormat('dd MMMM yyyy').format(detail.pickupDate!)
                        : 'Tidak ditentukan',
                  ),
                  const SizedBox(height: 20),
                  _buildDivider(),
                  const SizedBox(height: 20),
                  _buildInfoRow(
                    icon: Icons.event_busy_rounded,
                    label: 'Tanggal Kembali',
                    value: detail.returnDate != null
                        ? DateFormat('dd MMMM yyyy').format(detail.returnDate!)
                        : 'Tidak ditentukan',
                  ),
                ]
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPartnerCard(BuildContext context, PartnerInRequest partner) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Pemilik Barang'),
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
                _buildInfoRow(
                  icon: Icons.person_rounded,
                  label: 'Nama Pemilik',
                  value: partner.name,
                ),
                const SizedBox(height: 20),
                _buildDivider(),
                const SizedBox(height: 20),
                _buildInfoRow(
                  icon: Icons.location_on_rounded,
                  label: 'Alamat',
                  value: partner.address ?? 'Alamat tidak tersedia',
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: (partner.address != null &&
                                    partner.address!.isNotEmpty)
                                ? () async {
                                    final query =
                                        Uri.encodeComponent(partner.address!);
                                    final mapUrl = Uri.parse(
                                        'https://www.google.com/maps/search/?api=1&query=$query');
                                    if (await canLaunchUrl(mapUrl)) {
                                      await launchUrl(mapUrl);
                                    }
                                  }
                                : null,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.map_rounded,
                                    size: 18,
                                    color: (partner.address != null &&
                                            partner.address!.isNotEmpty)
                                        ? AppColors.primary
                                        : AppColors.disabled,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Buka Peta',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: (partner.address != null &&
                                              partner.address!.isNotEmpty)
                                          ? AppColors.primary
                                          : AppColors.disabled,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.donation,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: (partner.phone != null &&
                                    partner.phone!.isNotEmpty)
                                ? () async {
                                    final phone = partner.phone!.startsWith('0')
                                        ? '62${partner.phone!.substring(1)}'
                                        : partner.phone;
                                    final waUrl =
                                        Uri.parse('https://wa.me/$phone');
                                    if (await canLaunchUrl(waUrl)) {
                                      await launchUrl(waUrl,
                                          mode: LaunchMode.externalApplication);
                                    }
                                  }
                                : null,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_rounded,
                                    size: 18,
                                    color: (partner.phone != null &&
                                            partner.phone!.isNotEmpty)
                                        ? AppColors.textLight
                                        : AppColors.textLight.withOpacity(0.5),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Chat WA',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: (partner.phone != null &&
                                              partner.phone!.isNotEmpty)
                                          ? AppColors.textLight
                                          : AppColors.textLight
                                              .withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context, RequestDetail detail) {
    final statusInfo = _getStatusInfo(detail.status, detail.rejectionReason);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Status Permintaan'),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: statusInfo.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: statusInfo.color.withOpacity(0.3),
              width: 1.5,
            ),
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
                  child: Icon(
                    statusInfo.icon,
                    color: statusInfo.color,
                    size: 24,
                  ),
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
                          color: statusInfo.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusInfo.subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: statusInfo.color.withOpacity(0.8),
                          height: 1.4,
                        ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 16,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      width: double.infinity,
      color: AppColors.divider.withOpacity(0.3),
    );
  }

  StatusInfo _getStatusInfo(String status, String? rejectionReason) {
    switch (status.toLowerCase()) {
      case 'approved':
        return StatusInfo(
          icon: Icons.check_circle_rounded,
          color: AppColors.success,
          title: 'Permintaan Diterima',
          subtitle: 'Silakan hubungi pemilik untuk proses selanjutnya',
          backgroundColor: AppColors.success.withOpacity(0.05),
        );
      case 'completed':
        return StatusInfo(
          icon: Icons.verified_rounded,
          color: AppColors.success,
          title: 'Permintaan Selesai',
          subtitle: 'Transaksi ini telah berhasil diselesaikan',
          backgroundColor: AppColors.success.withOpacity(0.05),
        );
      case 'rejected':
        return StatusInfo(
          icon: Icons.cancel_rounded,
          color: AppColors.error,
          title: 'Permintaan Ditolak',
          subtitle: rejectionReason != null && rejectionReason.isNotEmpty
              ? 'Alasan: $rejectionReason'
              : 'Tidak ada alasan spesifik yang diberikan',
          backgroundColor: AppColors.error.withOpacity(0.05),
        );
      default: // pending
        return StatusInfo(
          icon: Icons.schedule_rounded,
          color: AppColors.warning,
          title: 'Menunggu Persetujuan',
          subtitle: 'Pemilik barang sedang meninjau permintaan Anda',
          backgroundColor: AppColors.warning.withOpacity(0.05),
        );
    }
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
