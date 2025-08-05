import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/features/chat/domain/entities/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isUser;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isUser,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tampilan visual saat pesan dipilih
    final bubbleColor = isSelected
        ? (isUser ? AppColors.primaryDark : AppColors.goodCondition)
        : (isUser ? AppColors.primary : Colors.white);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(vertical: 2),
      decoration: isSelected
          ? BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            )
          : null,
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            _buildAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onTap: onTap,
              onLongPress: onLongPress,
              // Bungkus dengan `Material` agar tidak ada highlight kuning aneh
              child: Material(
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    _buildMessageContainer(context, bubbleColor),
                    const SizedBox(height: 6),
                    _buildTimestamp(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.smart_toy,
        color: AppColors.primary,
        size: 18,
      ),
    );
  }

  Widget _buildMessageContainer(BuildContext context, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16).copyWith(
          bottomLeft:
              isUser ? const Radius.circular(16) : const Radius.circular(4),
          bottomRight:
              isUser ? const Radius.circular(4) : const Radius.circular(16),
        ),
        border: isUser || isSelected
            ? null
            : Border.all(color: AppColors.divider, width: 1),
      ),
      child: Text(
        message.content,
        style: TextStyle(
          color: isUser ? Colors.white : AppColors.textPrimary,
          fontSize: 15,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildTimestamp() {
    final localTimestamp = message.timestamp.toLocal();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        DateFormat.Hm('id_ID').format(localTimestamp),
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textHint,
        ),
      ),
    );
  }
}
