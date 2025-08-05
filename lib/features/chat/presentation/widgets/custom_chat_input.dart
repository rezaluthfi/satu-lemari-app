import 'package:flutter/material.dart';
import 'package:satulemari/core/constants/app_colors.dart';

class CustomChatInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSend;
  final bool enabled;

  const CustomChatInput({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<CustomChatInput> createState() => _CustomChatInputState();
}

class _CustomChatInputState extends State<CustomChatInput> {
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateSendButton);
    _updateSendButton();
  }

  @override
  void didUpdateWidget(covariant CustomChatInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      _updateSendButton();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateSendButton);
    super.dispose();
  }

  void _updateSendButton() {
    if (!mounted) return;
    final canSend = widget.controller.text.trim().isNotEmpty && widget.enabled;
    if (canSend != _canSend) {
      setState(() {
        _canSend = canSend;
      });
    }
  }

  void _handleSend() {
    if (_canSend) {
      widget.onSend(widget.controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                enabled: widget.enabled,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: widget.enabled
                      ? 'Ketik pesan...'
                      : 'AI sedang memproses...',
                  hintStyle:
                      const TextStyle(color: AppColors.textHint, fontSize: 15),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                style:
                    const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                onSubmitted: widget.enabled ? (_) => _handleSend() : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: _canSend ? AppColors.primary : AppColors.disabled,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _canSend ? _handleSend : null,
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
