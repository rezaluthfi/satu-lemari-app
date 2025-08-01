import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/features/history/domain/entities/request_item.dart';
import 'package:satulemari/features/history/presentation/bloc/history_bloc.dart';

class RequestListView extends StatelessWidget {
  final String type;
  // --- MODIFIKASI: Terima daftar request secara langsung ---
  final List<RequestItem> requests;

  const RequestListView(
      {super.key, required this.type, required this.requests});

  @override
  Widget build(BuildContext context) {
    // Langsung build ListView dari data yang diterima.
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _buildRequestCard(context, request);
      },
    );
  }

  Widget _buildRequestCard(BuildContext context, RequestItem request) {
    final statusInfo = _getStatusInfo(request.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            Navigator.pushNamed(context, '/request-detail',
                    arguments: request.id)
                .then((result) {
              // Jika result adalah true (artinya ada perubahan), refresh
              if (result == true) {
                context.read<HistoryBloc>().add(FetchHistory(type: type));
              }
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      imageUrl: request.imageUrl ?? '',
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              request.itemName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildStatusBadge(statusInfo),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('dd MMM yyyy').format(request.createdAt),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Text(
                            'Lihat detail',
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
    );
  }

  StatusInfo _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return StatusInfo(
          icon: Icons.check_circle_rounded,
          color: AppColors.success,
          label: 'Selesai',
          backgroundColor: AppColors.success.withOpacity(0.1),
        );
      case 'approved':
        return StatusInfo(
          icon: Icons.check_circle_rounded,
          color: AppColors.success,
          label: 'Disetujui',
          backgroundColor: AppColors.success.withOpacity(0.1),
        );
      case 'rejected':
        return StatusInfo(
          icon: Icons.cancel_rounded,
          color: AppColors.error,
          label: 'Ditolak',
          backgroundColor: AppColors.error.withOpacity(0.1),
        );
      default: // pending
        return StatusInfo(
          icon: Icons.schedule_rounded,
          color: AppColors.warning,
          label: 'Menunggu',
          backgroundColor: AppColors.warning.withOpacity(0.1),
        );
    }
  }

  Widget _buildStatusBadge(StatusInfo statusInfo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusInfo.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusInfo.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusInfo.icon,
            size: 12,
            color: statusInfo.color,
          ),
          const SizedBox(width: 4),
          Text(
            statusInfo.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: statusInfo.color,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusInfo {
  final IconData icon;
  final Color color;
  final String label;
  final Color backgroundColor;

  StatusInfo({
    required this.icon,
    required this.color,
    required this.label,
    required this.backgroundColor,
  });
}
