import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/core/di/injection.dart';
import 'package:satulemari/features/history/domain/entities/request_detail.dart';
import 'package:satulemari/features/history/presentation/bloc/request_detail_bloc.dart';
import 'package:satulemari/shared/widgets/custom_button.dart';
import 'package:satulemari/shared/widgets/loading_widget.dart';
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
        appBar: AppBar(
          title: const Text('Detail Permintaan'),
          backgroundColor: AppColors.primary,
        ),
        body: BlocBuilder<RequestDetailBloc, RequestDetailState>(
          builder: (context, state) {
            if (state is RequestDetailLoading ||
                state is RequestDetailInitial) {
              return const LoadingWidget();
            }
            if (state is RequestDetailError) {
              return Center(child: Text(state.message));
            }
            if (state is RequestDetailLoaded) {
              return _buildContent(context, state.detail);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, RequestDetail detail) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildItemInfo(context, detail.item),
              const SizedBox(height: 24),
              _buildRequestInfo(context, detail),
              const SizedBox(height: 24),
              _buildPartnerInfo(context, detail.partner),
              const SizedBox(height: 24),
              _buildStatusInfo(context, detail),
            ],
          ),
        ),
        _buildBottomAction(context, detail),
      ],
    );
  }

  Widget _buildItemInfo(BuildContext context, ItemInRequest item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Barang yang Diajukan',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl ?? '',
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorWidget: (c, u, e) => Container(
                    color: AppColors.surfaceVariant,
                    child: const Icon(Icons.inventory_2_outlined)),
              ),
            ),
            title: Text(item.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Lihat Detail Barang'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/item-detail', arguments: item.id);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRequestInfo(BuildContext context, RequestDetail detail) {
    final bool isDonation = detail.type == 'donation';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detail Permintaan Anda',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildInfoRow(
                    context,
                    Icons.calendar_today_outlined,
                    'Tanggal Permintaan',
                    DateFormat('dd MMMM yyyy, HH:mm').format(detail.createdAt)),
                if (isDonation &&
                    detail.reason != null &&
                    detail.reason!.isNotEmpty) ...[
                  const Divider(height: 24),
                  _buildInfoRow(
                      context, Icons.notes_outlined, 'Alasan', detail.reason!),
                ],
                if (!isDonation) ...[
                  const Divider(height: 24),
                  _buildInfoRow(
                      context,
                      Icons.calendar_view_day_outlined,
                      'Tanggal Ambil',
                      detail.pickupDate != null
                          ? DateFormat('dd MMMM yyyy')
                              .format(detail.pickupDate!)
                          : '-'),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                      context,
                      Icons.calendar_view_day_rounded,
                      'Tanggal Kembali',
                      detail.returnDate != null
                          ? DateFormat('dd MMMM yyyy')
                              .format(detail.returnDate!)
                          : '-'),
                ]
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPartnerInfo(BuildContext context, PartnerInRequest partner) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Informasi Pemilik',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildInfoRow(
                    context, Icons.person_outline, 'Nama', partner.name),
                const Divider(height: 24),
                _buildInfoRow(context, Icons.location_on_outlined, 'Alamat',
                    partner.address ?? 'Tidak ada alamat'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Buka Peta',
                        onPressed: (partner.address != null &&
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
                        type: ButtonType.outline,
                        height: 40,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Chat (WA)',
                        onPressed: (partner.phone != null &&
                                partner.phone!.isNotEmpty)
                            ? () async {
                                final phone = partner.phone!.startsWith('0')
                                    ? '62${partner.phone!.substring(1)}'
                                    : partner.phone;
                                final waUrl = Uri.parse('https://wa.me/$phone');
                                if (await canLaunchUrl(waUrl)) {
                                  await launchUrl(waUrl,
                                      mode: LaunchMode.externalApplication);
                                }
                              }
                            : null,
                        backgroundColor: AppColors.donation,
                        height: 40,
                        fontSize: 14,
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

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusInfo(BuildContext context, RequestDetail detail) {
    IconData icon;
    Color color;
    String title;
    String subtitle;

    switch (detail.status) {
      case 'approved':
      case 'completed':
        icon = Icons.check_circle_outline;
        color = AppColors.success;
        title = 'Permintaan Diterima';
        subtitle = 'Silakan ikuti panduan pengambilan barang di bawah ini.';
        break;
      case 'rejected':
        icon = Icons.cancel_outlined;
        color = AppColors.error;
        title = 'Permintaan Ditolak';
        subtitle =
            'Alasan: ${(detail.rejectionReason != null && detail.rejectionReason!.isNotEmpty) ? detail.rejectionReason! : "Tidak ada alasan spesifik."}';
        break;
      default: // pending
        icon = Icons.hourglass_empty;
        color = AppColors.warning;
        title = 'Menunggu Persetujuan';
        subtitle = 'Pemilik barang sedang meninjau permintaan Anda.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status Permintaan',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          color: color.withOpacity(0.05),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: color.withOpacity(0.3))),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color,
                              fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: TextStyle(
                              color: color.withOpacity(0.8), fontSize: 12)),
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildBottomAction(BuildContext context, RequestDetail detail) {
    if (detail.status != 'approved') {
      return const SizedBox.shrink();
    }

    final isDonation = detail.type == 'donation';
    final buttonText =
        isDonation ? 'Konfirmasi Barang Diterima' : 'Konfirmasi Pengembalian';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDonation) ...[
            const Text('Panduan Pengambilan:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                '1. Hubungi pemilik melalui WhatsApp untuk menyepakati waktu.\n2. Lakukan pengambilan di lokasi yang tertera.\n3. Setelah barang diterima, tekan tombol konfirmasi di bawah.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
          ],
          CustomButton(
            text: buttonText,
            onPressed: () {
              // TODO: Implementasi konfirmasi
            },
            width: double.infinity,
          )
        ],
      ),
    );
  }
}
