// lib/features/chat/presentation/widgets/suggestion_section.dart
import 'package:flutter/material.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/features/chat/domain/entities/chat_suggestion.dart';

class SuggestionSection extends StatelessWidget {
  final List<ChatSuggestion> suggestions;
  final Function(String) onSuggestionTapped;

  const SuggestionSection({
    Key? key,
    required this.suggestions,
    required this.onSuggestionTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Coba tanyakan ini:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSuggestionGrid(context),
        ],
      ),
    );
  }

  Widget _buildSuggestionGrid(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: suggestions.map((suggestion) {
        return _buildSuggestionChip(context, suggestion);
      }).toList(),
    );
  }

  Widget _buildSuggestionChip(BuildContext context, ChatSuggestion suggestion) {
    return InkWell(
      onTap: () => onSuggestionTapped(suggestion.text),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIconForSuggestion(suggestion.text),
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                suggestion.text,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForSuggestion(String text) {
    final lowerText = text.toLowerCase();
    if (lowerText.contains('outfit') || lowerText.contains('kombinasi')) {
      return Icons.checkroom;
    } else if (lowerText.contains('trend') || lowerText.contains('tren')) {
      return Icons.trending_up;
    } else if (lowerText.contains('warna') || lowerText.contains('color')) {
      return Icons.palette;
    } else if (lowerText.contains('perawatan') || lowerText.contains('cuci')) {
      return Icons.local_laundry_service;
    } else if (lowerText.contains('acara') || lowerText.contains('event')) {
      return Icons.event;
    } else if (lowerText.contains('budget') || lowerText.contains('harga')) {
      return Icons.attach_money;
    } else if (lowerText.contains('ukuran') || lowerText.contains('size')) {
      return Icons.straighten;
    } else if (lowerText.contains('musim') || lowerText.contains('cuaca')) {
      return Icons.wb_sunny;
    } else {
      return Icons.chat_bubble_outline;
    }
  }
}
