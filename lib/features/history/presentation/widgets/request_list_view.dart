import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/features/history/domain/entities/request_item.dart';
import 'package:satulemari/features/history/presentation/bloc/history_bloc.dart';
import 'package:satulemari/shared/widgets/loading_widget.dart';

class RequestListView extends StatelessWidget {
  final String type;
  const RequestListView({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        final status =
            type == 'donation' ? state.donationStatus : state.rentalStatus;
        final requests =
            type == 'donation' ? state.donationRequests : state.rentalRequests;
        final error =
            type == 'donation' ? state.donationError : state.rentalError;

        if (status == HistoryStatus.loading ||
            status == HistoryStatus.initial) {
          return const LoadingWidget();
        }
        if (status == HistoryStatus.error) {
          return Center(child: Text(error ?? 'Terjadi kesalahan'));
        }
        if (requests.isEmpty) {
          return const Center(
              child: Text('Tidak ada riwayat untuk ditampilkan.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _buildRequestCard(context, request);
          },
        );
      },
    );
  }

  Widget _buildRequestCard(BuildContext context, RequestItem request) {
    IconData icon;
    Color color;
    switch (request.status) {
      case 'approved':
      case 'completed':
        icon = Icons.check_circle;
        color = AppColors.success;
        break;
      case 'rejected':
        icon = Icons.cancel;
        color = AppColors.error;
        break;
      default: // pending
        icon = Icons.hourglass_top;
        color = AppColors.warning;
    }

    return Card(
      elevation: 2,
      shadowColor: AppColors.shadow.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: request.imageUrl ?? '',
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorWidget: (c, u, e) => Container(
                color: AppColors.surfaceVariant,
                child: const Icon(Icons.inventory_2_outlined)),
          ),
        ),
        title: Text(request.itemName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            'Diajukan pada ${DateFormat('dd MMM yyyy').format(request.createdAt)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(request.status,
                style: TextStyle(
                    color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(context, '/request-detail',
              arguments: request.id);
        },
      ),
    );
  }
}
