// lib/features/chat/presentation/pages/chat_sessions_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/core/di/injection.dart';
import 'package:satulemari/core/utils/fab_position_manager.dart';
import 'package:satulemari/shared/widgets/confirmation_dialog.dart';
import 'package:satulemari/features/chat/domain/entities/chat_session.dart';
import 'package:satulemari/features/chat/presentation/bloc/sessions_bloc.dart';
import 'package:satulemari/features/chat/presentation/pages/chat_page.dart';
import 'package:satulemari/features/chat/presentation/widgets/session_list_shimmer.dart';

class ChatSessionsPage extends StatelessWidget {
  const ChatSessionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<SessionsBloc>()..add(const FetchSessions()),
      child: const ChatSessionsView(),
    );
  }
}

class ChatSessionsView extends StatefulWidget {
  const ChatSessionsView({Key? key}) : super(key: key);

  @override
  State<ChatSessionsView> createState() => _ChatSessionsViewState();
}

class _ChatSessionsViewState extends State<ChatSessionsView> {
  // FAB position variables
  double _fabX = 0;
  double _fabY = 0;
  bool _fabInitialized = false;

  // Safe area constraints for FAB
  static const double _topSafeZone = 0; // App bar + status bar
  static const double _bottomSafeZone = 80.0; // Bottom safe area
  static const double _sidePadding = 16.0;
  static const double _fabSize = 56.0;

  // FAB Position Manager
  final FabPositionManager _positionManager = FabPositionManager();

  @override
  void dispose() {
    if (_fabInitialized) {
      _positionManager.savePosition(
        FabPositionManager.chatSessionsPageKey,
        _fabX,
        _fabY,
      );
    }
    super.dispose();
  }

  void _handleNavigationResult(BuildContext context, dynamic result) {
    if (result == true) {
      context.read<SessionsBloc>().add(const FetchSessions(forceRefresh: true));
    }
  }

  void _startNewChat(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const ChatPage(args: ChatPageArguments(sessionId: null)),
      ),
    );
    // Selalu refresh sessions setelah kembali dari chat baru
    if (context.mounted) {
      context.read<SessionsBloc>().add(const FetchSessions(forceRefresh: true));
    }
  }

  void _continueChat(BuildContext context, String sessionId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(args: ChatPageArguments(sessionId: sessionId)),
      ),
    );
    if (context.mounted) {
      _handleNavigationResult(context, result);
    }
  }

  void _confirmDeleteAll(BuildContext context) {
    ConfirmationDialog.showDeleteConfirmation(
      context: context,
      title: 'Hapus Semua Riwayat',
      content:
          'Apakah Anda yakin? Tindakan ini tidak dapat dibatalkan dan akan menghapus semua sesi percakapan Anda.',
      onConfirm: () {
        context.read<SessionsBloc>().add(DeleteAllUserHistoryEvent());
      },
      icon: const Icon(Icons.delete_sweep, color: AppColors.error, size: 24),
    );
  }

  void _initializeFabPosition() {
    if (!_fabInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final screenSize = MediaQuery.of(context).size;
          final savedPosition = _positionManager
              .getPosition(FabPositionManager.chatSessionsPageKey);
          setState(() {
            if (savedPosition != null) {
              _fabX = savedPosition.x.clamp(
                  _sidePadding, screenSize.width - _fabSize - _sidePadding);
              _fabY = savedPosition.y.clamp(
                  _topSafeZone, screenSize.height - _bottomSafeZone - _fabSize);
            } else {
              final defaultPosition = _positionManager.getDefaultPosition(
                FabPositionManager.chatSessionsPageKey,
                screenSize.width,
                screenSize.height,
              );
              _fabX = defaultPosition.x;
              _fabY = defaultPosition.y;
            }
            _fabInitialized = true;
          });
        }
      });
    }
  }

  void _onFabPanUpdate(DragUpdateDetails details) {
    final screenSize = MediaQuery.of(context).size;
    setState(() {
      _fabX = (_fabX + details.delta.dx)
          .clamp(_sidePadding, screenSize.width - _fabSize - _sidePadding);
      _fabY = (_fabY + details.delta.dy)
          .clamp(_topSafeZone, screenSize.height - _bottomSafeZone - _fabSize);
    });
    _positionManager.savePosition(
      FabPositionManager.chatSessionsPageKey,
      _fabX,
      _fabY,
    );
  }

  @override
  Widget build(BuildContext context) {
    _initializeFabPosition();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        title: Row(
          children: [
            Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.smart_toy_outlined,
                    color: Colors.white, size: 20)),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SatuLemari AI',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                Text('Asisten Fashion Pintar',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
        actions: [
          BlocBuilder<SessionsBloc, SessionsState>(
            builder: (context, state) {
              if (state is SessionsLoaded && state.sessions.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined,
                      color: AppColors.error),
                  tooltip: 'Hapus Semua Riwayat',
                  onPressed: () => _confirmDeleteAll(context),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // --- BLOC CONSUMER YANG SUDAH DISESUAIKAN ---
          BlocConsumer<SessionsBloc, SessionsState>(
            listener: (context, state) {
              if (state is SessionsLoaded) {
                const double fabBottomClearance = 92.0;

                if (state.successMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.successMessage!),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      elevation: 0,
                      margin: const EdgeInsets.fromLTRB(
                          12, 12, 12, fabBottomClearance),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                } else if (state.failureMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.failureMessage!),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      // <-- PERBAIKAN: Beri margin bawah yang lebih besar
                      margin: const EdgeInsets.fromLTRB(
                          12, 12, 12, fabBottomClearance),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }
              }
            },
            builder: (context, state) {
              if (state is SessionsLoading || state is SessionsInitial) {
                return const SessionListShimmer();
              }
              if (state is SessionsError) {
                return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 48),
                      const SizedBox(height: 16),
                      const Text('Terjadi Kesalahan',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 14)),
                      )
                    ]));
              }
              if (state is SessionsLoaded) {
                if (state.sessions.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16)),
                              child: const Icon(Icons.chat_bubble_outline,
                                  size: 64, color: AppColors.primary)),
                          const SizedBox(height: 24),
                          const Text('Mulai Percakapan Pertama',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 12),
                          const Text(
                              'Belum ada riwayat percakapan.\nTekan tombol + untuk mulai berbicara dengan SatuLemari AI.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                  height: 1.5)),
                        ])),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => context
                      .read<SessionsBloc>()
                      .add(const FetchSessions(forceRefresh: true)),
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.sessions.length,
                    itemBuilder: (context, index) {
                      final session = state.sessions[index];
                      return _buildSessionTile(context, session, index);
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          if (_fabInitialized)
            Positioned(
              left: _fabX,
              top: _fabY,
              child: GestureDetector(
                onPanUpdate: _onFabPanUpdate,
                child: FloatingActionButton(
                  onPressed: () => _startNewChat(context),
                  backgroundColor: AppColors.primary,
                  elevation: 6,
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSessionTile(
      BuildContext context, ChatSession session, int index) {
    final localLastActivity = session.lastActivity.toLocal();
    final isToday = DateFormat.yMd().format(localLastActivity) ==
        DateFormat.yMd().format(DateTime.now());
    final isYesterday = DateFormat.yMd().format(localLastActivity) ==
        DateFormat.yMd()
            .format(DateTime.now().subtract(const Duration(days: 1)));
    final String titleText;
    if (isToday) {
      titleText = 'Percakapan Hari Ini';
    } else if (isYesterday) {
      titleText = 'Percakapan Kemarin';
    } else {
      titleText =
          'Percakapan ${DateFormat.yMMMd('id_ID').format(localLastActivity)}';
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(session.id),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          context
              .read<SessionsBloc>()
              .add(DeleteSpecificSessionEvent(session.id));
        },
        background: Container(
          decoration: BoxDecoration(
              color: AppColors.error, borderRadius: BorderRadius.circular(8)),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete, color: Colors.white, size: 24),
                SizedBox(height: 4),
                Text('Hapus',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold))
              ]),
        ),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.divider)),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.chat_bubble_outline,
                    color: AppColors.primary, size: 20)),
            title: Text(titleText,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                    'Aktivitas terakhir: Pukul ${DateFormat.Hm('id_ID').format(localLastActivity)}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13))),
            trailing: const Icon(Icons.chevron_right_rounded,
                color: AppColors.textHint),
            onTap: () => _continueChat(context, session.id),
          ),
        ),
      ),
    );
  }
}
