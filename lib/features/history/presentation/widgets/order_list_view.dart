import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/features/order/domain/entities/order_item.dart';

class OrderListView extends StatelessWidget {
  final List<OrderItem> orders;
  const OrderListView({super.key, required this.orders});

  String _formatCurrency(int amount) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(amount);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Tambahkan ScrollController
    return ListView.builder(
      padding: const EdgeInsets.all(20.0),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: AppColors.divider.withOpacity(0.3), width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.pushNamed(context, '/order-detail',
                    arguments: order.id);
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: order.itemImageUrl != null
                            ? CachedNetworkImage(imageUrl: order.itemImageUrl!)
                            : Container(
                                color: AppColors.surfaceVariant,
                                child: const Icon(Icons.inventory_2_outlined)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.itemName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(
                            'Status: ${order.status.capitalize()}',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total: ${_formatCurrency(order.totalAmount)}',
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textHint),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).replaceAll('_', ' ')}";
  }
}
