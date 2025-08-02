// lib/features/chat/presentation/pages/chat_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/core/di/injection.dart';
import 'package:satulemari/shared/widgets/confirmation_dialog.dart';
import 'package:satulemari/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:satulemari/features/chat/presentation/widgets/chat_page_shimmer.dart';
import 'package:satulemari/features/chat/presentation/widgets/custom_chat_input.dart';
import 'package:satulemari/features/chat/presentation/widgets/message_bubble.dart';
import 'package:satulemari/features/chat/presentation/widgets/quick_reply_section.dart';
import 'package:satulemari/features/chat/presentation/widgets/suggestion_section.dart';
import 'package:satulemari/features/chat/presentation/widgets/typing_indicator.dart';

class ChatPageArguments {
  final String? sessionId;
  const ChatPageArguments({this.sessionId});
}

class ChatPage extends StatelessWidget {
  final ChatPageArguments args;
  const ChatPage({Key? key, required this.args}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ChatBloc>()
        ..add(InitializeChat(existingSessionId: args.sessionId)),
      child: const ChatView(),
    );
  }
}

class ChatView extends StatefulWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  bool _didChatActivityOccur = false;
  bool _isSelectionMode = false;
  final Set<String> _selectedMessageIds = {};
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _didChatActivityOccur = true;
    });
    context.read<ChatBloc>().add(SendTextMessage(text));
    _textController.clear();
  }

  void _showSessionOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text('Opsi Percakapan',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
              ),
              ListTile(
                leading:
                    const Icon(Icons.delete_sweep, color: AppColors.warning),
                title: const Text('Hapus Pesan di Sesi Ini',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                subtitle: const Text('Hapus semua pesan dalam percakapan ini',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmClearMessages(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmClearMessages(BuildContext context) {
    ConfirmationDialog.showDeleteConfirmation(
      context: context,
      title: 'Hapus Pesan',
      content:
          'Apakah Anda yakin ingin menghapus semua pesan dalam percakapan ini?',
      onConfirm: () {
        setState(() {
          _didChatActivityOccur = true;
        });
        context.read<ChatBloc>().add(ClearSessionMessages());
      },
      icon: const Icon(Icons.delete_sweep, color: AppColors.error, size: 24),
    );
  }

  void _toggleSelectionMode(String messageId) {
    if (_isSelectionMode) return;
    setState(() {
      _isSelectionMode = true;
      _selectedMessageIds.add(messageId);
    });
  }

  void _toggleMessageSelection(String messageId) {
    setState(() {
      if (_selectedMessageIds.contains(messageId)) {
        _selectedMessageIds.remove(messageId);
        if (_selectedMessageIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedMessageIds.add(messageId);
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedMessageIds.clear();
    });
  }

  void _confirmDeleteSelectedMessages(BuildContext context) {
    ConfirmationDialog.showDeleteConfirmation(
      context: context,
      title: 'Hapus ${_selectedMessageIds.length} Pesan',
      content: 'Apakah Anda yakin ingin menghapus pesan yang dipilih?',
      onConfirm: () {
        setState(() {
          _didChatActivityOccur = true;
        });
        context
            .read<ChatBloc>()
            .add(DeleteSelectedMessagesEvent(_selectedMessageIds.toList()));
        _exitSelectionMode();
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    if (_isSelectionMode) {
      return AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _exitSelectionMode,
          style: IconButton.styleFrom(
            foregroundColor: Colors.white,
          ),
        ),
        title: Text(
          '${_selectedMessageIds.length} Dipilih',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error),
              onPressed: () => _confirmDeleteSelectedMessages(context),
              style: IconButton.styleFrom(
                foregroundColor: AppColors.error,
                backgroundColor: AppColors.error.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              tooltip: 'Hapus yang Dipilih',
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.primary.withOpacity(0.3),
          ),
        ),
      );
    }

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textPrimary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context, _didChatActivityOccur);
        },
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SatuLemari AI',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              Text('Asisten Fashion',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
      actions: [
        BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            if (state is ChatLoaded && state.messages.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
                onPressed: () => _showSessionOptions(context),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isSelectionMode) {
          _exitSelectionMode();
          return false;
        }
        Navigator.pop(context, _didChatActivityOccur);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: BlocConsumer<ChatBloc, ChatState>(
          listener: (context, state) {
            if (state is ChatLoaded && state.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  elevation: 0,
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
              context
                  .read<ChatBloc>()
                  .emit(state.copyWith(clearSuccessMessage: true));
            } else if (state is ChatError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }
            if (state is ChatLoaded) {
              _scrollToBottom();
            }
          },
          builder: (context, state) {
            if (state is ChatInitial || state is ChatLoading) {
              return const ChatPageShimmer();
            }
            if (state is ChatError) {
              return Center(child: Text(state.message));
            }
            if (state is ChatLoaded) {
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: state.messages.length + 1,
                      itemBuilder: (context, index) {
                        if (index < state.messages.length) {
                          final message = state.messages[index];
                          final isSelected =
                              _selectedMessageIds.contains(message.id);
                          return MessageBubble(
                            message: message,
                            isUser: message.role == 'user',
                            isSelected: isSelected,
                            onTap: _isSelectionMode
                                ? () => _toggleMessageSelection(message.id)
                                : null,
                            onLongPress: !_isSelectionMode
                                ? () => _toggleSelectionMode(message.id)
                                : null,
                          );
                        }
                        if (state.suggestions.isNotEmpty) {
                          return SuggestionSection(
                              suggestions: state.suggestions,
                              onSuggestionTapped: _sendMessage);
                        }
                        if (state.isBotTyping) {
                          return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: TypingIndicator());
                        }
                        return const SizedBox(height: 16);
                      },
                    ),
                  ),
                  if (!_isSelectionMode) _buildBottomSection(state),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildBottomSection(ChatLoaded state) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.quickReplies.isNotEmpty)
            QuickReplySection(
              replies: state.quickReplies,
              onQuickReplyTapped: (reply) {
                setState(() {
                  _didChatActivityOccur = true;
                });
                context.read<ChatBloc>().add(QuickReplyTapped(reply));
              },
            ),
          CustomChatInput(
            controller: _textController,
            focusNode: _focusNode,
            onSend: _sendMessage,
            enabled: !state.isBotTyping,
          ),
        ],
      ),
    );
  }
}
