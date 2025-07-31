// lib/features/chat/presentation/widgets/quick_reply_section.dart
import 'package:flutter/material.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/features/chat/domain/entities/quick_reply.dart';

class QuickReplySection extends StatelessWidget {
  final List<QuickReply> replies;
  final Function(QuickReply) onQuickReplyTapped;

  const QuickReplySection({
    Key? key,
    required this.replies,
    required this.onQuickReplyTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(
                  Icons.flash_on,
                  size: 16,
                  color: AppColors.accent,
                ),
                SizedBox(width: 6),
                Text(
                  'Respons Cepat',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: replies.asMap().entries.map((entry) {
                final index = entry.key;
                final reply = entry.value;
                return Container(
                  margin: EdgeInsets.only(
                    right: index < replies.length - 1 ? 12 : 0,
                  ),
                  child: _buildQuickReplyChip(context, reply),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplyChip(BuildContext context, QuickReply reply) {
    return InkWell(
      onTap: () => onQuickReplyTapped(reply),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (reply.icon != null) ...[
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  reply.icon!,
                  style: const TextStyle(fontSize: 10),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              reply.text,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.send,
              size: 12,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
