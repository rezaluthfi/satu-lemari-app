// File: lib/features/notification/presentation/pages/notification_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/features/notification/domain/entities/notification_entity.dart';
import 'package:satulemari/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:satulemari/features/notification/presentation/widgets/notification_shimmer.dart';
import 'package:satulemari/shared/widgets/loading_widget.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};
  NotificationState? _previousState;
  bool _wasDeleting = false; // Flag untuk track status delete

  @override
  void initState() {
    super.initState();
    // Memuat notifikasi saat halaman pertama kali dibuka
    // Menggunakan BLoC yang sudah ada dari context
    context.read<NotificationBloc>().add(FetchNotifications());
  }

  void _toggleSelectionMode() {
    if (mounted) {
      setState(() {
        _isSelectionMode = !_isSelectionMode;
        if (!_isSelectionMode) {
          _selectedIds.clear();
        }
      });
    }
  }

  void _onItemSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _deleteSelectedItems() {
    if (_selectedIds.isEmpty) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Notifikasi'),
        content:
            Text('Yakin ingin menghapus ${_selectedIds.length} notifikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              // Set flag bahwa kita sedang melakukan delete multiple
              _wasDeleting = true;

              context.read<NotificationBloc>().add(
                    DeleteMultipleNotifications(_selectedIds.toList()),
                  );
              Navigator.pop(dialogContext);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(NotificationEntity notification) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Notifikasi'),
        content: const Text('Yakin ingin menghapus notifikasi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              context
                  .read<NotificationBloc>()
                  .add(DeleteNotification(notification.id));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // Helper method untuk mengecek apakah operasi memerlukan loading overlay
  bool _shouldShowLoadingOverlay(NotificationState state) {
    // Tidak tampilkan loading overlay untuk semua operasi
    // Biarkan user tetap berinteraksi dengan UI
    return false;
  }

  void _exitSelectionMode() {
    if (mounted) {
      setState(() {
        _isSelectionMode = false;
        _selectedIds.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // KUNCI PERBAIKAN: HAPUS BlocProvider dari sini.
    // Widget ini sekarang mengandalkan BLoC yang diberikan oleh BlocProvider.value dari HomePage.
    return BlocConsumer<NotificationBloc, NotificationState>(
      listener: (context, state) {
        // PERBAIKAN UTAMA: Deteksi berhasilnya operasi delete multiple
        if (_previousState != null) {
          // Jika sebelumnya sedang submitting (delete) dan sekarang sudah selesai tanpa error
          bool wasSubmittingBefore = _previousState!.isSubmitting;
          bool isNotSubmittingNow = !state.isSubmitting;
          bool noError = state.errorMessage == null;

          // Dan jika kita memang sedang dalam proses delete multiple
          if (wasSubmittingBefore &&
              isNotSubmittingNow &&
              noError &&
              _wasDeleting) {
            // Reset flag dan keluar dari selection mode
            _wasDeleting = false;
            _exitSelectionMode();
          }
        }

        // Simpan state sekarang untuk referensi selanjutnya
        _previousState = state;

        // Tampilkan error jika ada
        if (state.errorMessage != null && !state.isSubmitting) {
          // Reset flag jika ada error
          _wasDeleting = false;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.errorMessage!)),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.background,
              appBar: _buildAppBar(state),
              body: _buildBody(state),
            ),
            // Hanya tampilkan loading overlay untuk operasi delete
            if (_shouldShowLoadingOverlay(state))
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const LoadingWidget(
                  message: 'Memproses...',
                  color: Colors.white,
                ),
              ),
          ],
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(NotificationState state) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.primary,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Colors.white,
      title: Text(
        _isSelectionMode ? '${_selectedIds.length} Dipilih' : 'Notifikasi',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      leading: _isSelectionMode
          ? IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: _shouldShowLoadingOverlay(state)
                  ? null
                  : _toggleSelectionMode,
              style: IconButton.styleFrom(
                foregroundColor: Colors.white,
              ),
            )
          : null,
      actions: [
        // PERBAIKAN: Wrap actions dalam Flexible untuk mencegah overflow
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isSelectionMode && _selectedIds.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: _shouldShowLoadingOverlay(state)
                        ? null
                        : _deleteSelectedItems,
                    style: IconButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    tooltip: 'Hapus yang Dipilih',
                  ),
                ),
              if (!_isSelectionMode)
                if (state.notifications.isNotEmpty)
                  if ((state.stats?.unreadCount ?? 0) > 0)
                    // PERBAIKAN: Buat button lebih kompak dan responsive
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Jika space terbatas, tampilkan hanya icon
                          bool isCompact =
                              MediaQuery.of(context).size.width < 380;

                          if (isCompact) {
                            return IconButton(
                              onPressed: _shouldShowLoadingOverlay(state)
                                  ? null
                                  : () {
                                      context
                                          .read<NotificationBloc>()
                                          .add(MarkAllAsRead());
                                    },
                              icon:
                                  const Icon(Icons.done_all_rounded, size: 20),
                              style: IconButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              tooltip: 'Tandai Semua Dibaca',
                            );
                          } else {
                            return TextButton.icon(
                              onPressed: _shouldShowLoadingOverlay(state)
                                  ? null
                                  : () {
                                      context
                                          .read<NotificationBloc>()
                                          .add(MarkAllAsRead());
                                    },
                              icon:
                                  const Icon(Icons.done_all_rounded, size: 18),
                              label: const Text(
                                'Tandai Dibaca',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                            );
                          }
                        },
                      ),
                    )
                  else
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        onPressed: _shouldShowLoadingOverlay(state)
                            ? null
                            : _toggleSelectionMode,
                        icon: const Icon(Icons.checklist_rounded),
                        style: IconButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        tooltip: 'Pilih Beberapa',
                      ),
                    ),
            ],
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

  Widget _buildBody(NotificationState state) {
    // Tampilkan shimmer saat loading dan belum ada data
    if (state.status == NotificationStatus.loading &&
        state.notifications.isEmpty) {
      return const NotificationShimmer();
    }

    if (state.status == NotificationStatus.error &&
        state.notifications.isEmpty) {
      return _buildErrorState(state.errorMessage ?? 'Gagal memuat notifikasi');
    }

    if (state.notifications.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        if (state.stats?.unreadCount != null && state.stats!.unreadCount > 0)
          _buildUnreadBanner(state.stats!.unreadCount),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<NotificationBloc>().add(FetchNotifications());
            },
            color: AppColors.primary,
            backgroundColor: Colors.white,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 1),
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                final isSelected = _selectedIds.contains(notification.id);
                return _buildNotificationCard(
                    context, notification, isSelected, state);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnreadBanner(int unreadCount) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.circle_notifications_rounded,
            color: AppColors.info,
            size: 20,
          ),
          const SizedBox(width: 8),
          // PERBAIKAN: Bungkus text dengan Flexible untuk mencegah overflow
          Flexible(
            child: Text(
              'Anda memiliki $unreadCount notifikasi yang belum dibaca',
              style: const TextStyle(
                color: AppColors.info,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          const Text(
            'Oops! Terjadi Kesalahan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<NotificationBloc>().add(FetchNotifications());
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 80,
            color: AppColors.textHint,
          ),
          SizedBox(height: 24),
          Text(
            'Belum Ada Notifikasi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Notifikasi akan muncul di sini ketika ada aktivitas baru di akun Anda',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
      BuildContext context,
      NotificationEntity notification,
      bool isSelected,
      NotificationState state) {
    final bool canNavigate = notification.data['request_id'] != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.08)
            : (notification.isRead
                ? Colors.white
                : AppColors.primary.withOpacity(0.03)),
        borderRadius: BorderRadius.circular(16),
        border: isSelected
            ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 1)
            : Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _shouldShowLoadingOverlay(state)
              ? null
              : () {
                  if (_isSelectionMode) {
                    _onItemSelect(notification.id);
                  } else if (canNavigate) {
                    context
                        .read<NotificationBloc>()
                        .add(NotificationTapped(notification));
                    Navigator.pushNamed(context, '/request-detail',
                        arguments: notification.data['request_id']);
                  }
                },
          onLongPress: _shouldShowLoadingOverlay(state)
              ? null
              : () {
                  if (!_isSelectionMode) {
                    _toggleSelectionMode();
                    _onItemSelect(notification.id);
                  }
                },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getColorForType(notification.type)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconForType(notification.type),
                        color: _getColorForType(notification.type),
                        size: 24,
                      ),
                    ),
                    if (!notification.isRead)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w600,
                                color: AppColors.textPrimary,
                                height: 1.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              _formatTime(notification.createdAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textHint,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.message,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (canNavigate) ...[
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 12,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Lihat Detail',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (_isSelectionMode)
                  Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isSelected ? AppColors.primary : AppColors.textHint,
                    size: 24,
                  )
                else
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textHint,
                      size: 18,
                    ),
                    onPressed: _shouldShowLoadingOverlay(state)
                        ? null
                        : () {
                            _showDeleteConfirmation(notification);
                          },
                    style: IconButton.styleFrom(
                      minimumSize: const Size(32, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    tooltip: 'Hapus notifikasi',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('dd/MM/yy').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}h lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}j lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m lalu';
    } else {
      return 'Baru saja';
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'request_created':
        return Icons.shopping_cart_rounded;
      case 'request_approved':
        return Icons.check_circle_rounded;
      case 'request_rejected':
        return Icons.cancel_rounded;
      case 'request_completed':
        return Icons.verified_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'request_created':
        return AppColors.info;
      case 'request_approved':
        return AppColors.success;
      case 'request_rejected':
        return AppColors.error;
      case 'request_completed':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }
}
