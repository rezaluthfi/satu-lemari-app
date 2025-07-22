import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/features/auth/presentation/bloc/auth_bloc.dart';
// --- IMPORT UNTUK RESET BLOC ---
import 'package:satulemari/features/history/presentation/bloc/history_bloc.dart';
import 'package:satulemari/features/home/presentation/bloc/home_bloc.dart';
import 'package:satulemari/features/notification/presentation/bloc/notification_bloc.dart';
// ---------------------------------
import 'package:satulemari/features/profile/domain/entities/dashboard_stats.dart';
import 'package:satulemari/features/profile/domain/entities/profile.dart';
import 'package:satulemari/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:satulemari/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:satulemari/features/profile/presentation/widgets/profile_shimmer.dart';
import 'package:satulemari/shared/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Memastikan data diambil jika state masih initial
    if (context.read<ProfileBloc>().state is ProfileInitial) {
      context.read<ProfileBloc>().add(FetchProfileData());
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is AccountDeleteSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Akun berhasil dihapus.'),
                backgroundColor: AppColors.success,
              ),
            );
            // Panggil event logout setelah akun berhasil dihapus
            context.read<AuthBloc>().add(LogoutButtonPressed());
          }
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoaded) {
              return _buildProfileContent(context, state.profile, state.stats);
            }
            if (state is ProfileError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.error,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Oops! Gagal Memuat Profil',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Coba Lagi',
                        onPressed: () =>
                            context.read<ProfileBloc>().add(FetchProfileData()),
                        icon: Icons.refresh,
                      ),
                    ],
                  ),
                ),
              );
            }
            return const ProfileShimmer();
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(
      BuildContext context, Profile profile, DashboardStats stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHeader(context, profile),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (profile.description != null &&
                            profile.description!.isNotEmpty) ...[
                          _buildDescriptionCard(profile.description!),
                          const SizedBox(height: 16),
                        ],
                        _buildStatsSection(stats), // Bagian statistik
                        const SizedBox(height: 16),
                        _buildDonationQuotaCard(profile),
                        const SizedBox(height: 16),
                        _buildContactCard(profile),
                        const SizedBox(height: 16),
                        if (profile.latitude != null &&
                            profile.longitude != null) ...[
                          _buildLocationCard(context, profile),
                        ],
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: _buildActionSection(context), // Bagian tombol aksi
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, Profile profile) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white.withOpacity(0.03),
                        child: profile.photo != null
                            ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: profile.photo!,
                                  fit: BoxFit.cover, // Gunakan cover agar pas
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(
                                          color: Colors.white),
                                  errorWidget: (context, url, error) =>
                                      const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile.fullName ?? profile.username,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${profile.username}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (profile.city != null && profile.city!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          profile.city!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: BlocProvider.of<ProfileBloc>(context),
                            child: const EditProfilePage(),
                          ),
                          settings: RouteSettings(
                            arguments: profile,
                          ),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Edit',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Text(
        description,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontStyle: FontStyle.italic,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // --- WIDGET STATISTIK YANG SUDAH DIMODIFIKASI ---
  Widget _buildStatsSection(DashboardStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistik Aktivitas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Donasi',
                stats.totalDonations.toString(),
                Icons.volunteer_activism_outlined,
                AppColors.donation,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Sewa',
                stats.totalRentals.toString(),
                Icons.shopping_bag_outlined,
                AppColors.rental,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDonationQuotaCard(Profile profile) {
    double progress = (profile.weeklyDonationQuota > 0)
        ? profile.weeklyDonationUsed / profile.weeklyDonationQuota
        : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.donation.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.favorite_outline,
                  color: AppColors.donation,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Kuota Donasi Mingguan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppColors.surfaceVariant,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.donation),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${profile.weeklyDonationUsed}/${profile.weeklyDonationQuota} donasi',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.donation,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // SESUDAH
          Text(
            'Reset pada: ${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.parse(profile.quotaResetDate))}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(Profile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.contact_page_outlined,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Informasi Kontak',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContactItem(Icons.email_outlined, 'Email', profile.email),
          _buildContactItem(
              Icons.phone_outlined, 'Telepon', profile.phone ?? 'Belum diatur'),
          _buildContactItem(
              Icons.home_outlined, 'Alamat', profile.address ?? 'Belum diatur'),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, Profile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Lokasi Tersimpan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            profile.address ?? 'Lokasi belum diatur',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Buka di Peta',
            onPressed: () async {
              final lat = profile.latitude;
              final lng = profile.longitude;
              final mapUrl = Uri.parse(
                  'https://www.google.com/maps/search/?api=1&query=$lat,$lng');

              if (await canLaunchUrl(mapUrl)) {
                await launchUrl(mapUrl);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tidak dapat membuka peta.')),
                );
              }
            },
            type: ButtonType.outline,
            icon: Icons.map_outlined,
          ),
        ],
      ),
    );
  }

  // --- WIDGET AKSI DENGAN LOGIKA LOGOUT YANG BENAR ---
  Widget _buildActionSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.settings_outlined,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Pengaturan Akun',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              return BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, profileState) {
                  final isAuthLoading = authState is AuthLoading;
                  final isProfileLoading =
                      profileState is AccountDeleteInProgress;
                  final isLoading = isAuthLoading || isProfileLoading;

                  return Column(
                    children: [
                      CustomButton(
                        text: 'Logout',
                        onPressed: isLoading
                            ? null
                            : () {
                                showDialog(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    title: const Text('Logout'),
                                    content: const Text(
                                        'Apakah Anda yakin ingin keluar?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(dialogContext).pop(),
                                        child: const Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // Tutup dialog terlebih dahulu
                                          Navigator.of(dialogContext).pop();

                                          // 1. Reset state semua BLoC yang relevan
                                          print(
                                              "Resetting all user-specific BLoC states...");
                                          context
                                              .read<ProfileBloc>()
                                              .add(ProfileReset());
                                          context
                                              .read<HistoryBloc>()
                                              .add(HistoryReset());
                                          context
                                              .read<HomeBloc>()
                                              .add(HomeReset());
                                          context
                                              .read<NotificationBloc>()
                                              .add(NotificationReset());

                                          // 2. Lanjutkan dengan proses logout
                                          context
                                              .read<AuthBloc>()
                                              .add(LogoutButtonPressed());
                                        },
                                        child: const Text(
                                          'Logout',
                                          style: TextStyle(
                                              color: AppColors.primary),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                        type: ButtonType.outline,
                        width: double.infinity,
                        icon: Icons.logout,
                        isLoading: isAuthLoading,
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        text: 'Hapus Akun',
                        onPressed: isLoading
                            ? null
                            : () {
                                showDialog(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    title: const Text('Hapus Akun'),
                                    content: const Text(
                                        'Tindakan ini tidak dapat diurungkan. Apakah Anda yakin?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(dialogContext).pop(),
                                        child: const Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(dialogContext).pop();
                                          context.read<ProfileBloc>().add(
                                              DeleteAccountButtonPressed());
                                        },
                                        child: const Text(
                                          'Hapus',
                                          style:
                                              TextStyle(color: AppColors.error),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                        type: ButtonType.text,
                        textColor: AppColors.error,
                        width: double.infinity,
                        icon: Icons.delete_forever_outlined,
                        isLoading: isProfileLoading,
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
