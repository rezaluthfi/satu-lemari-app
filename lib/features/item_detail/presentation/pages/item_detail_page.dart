// lib/features/item_detail/presentation/pages/item_detail_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // <-- PERUBAHAN: Import untuk format harga
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/core/di/injection.dart';
import 'package:satulemari/core/utils/string_extensions.dart';
import 'package:satulemari/features/item_detail/domain/entities/item_detail.dart';
import 'package:satulemari/features/item_detail/presentation/bloc/item_detail_bloc.dart';
import 'package:satulemari/features/item_detail/presentation/pages/full_screen_image_viewer.dart';
import 'package:satulemari/features/item_detail/presentation/widgets/item_detail_shimmer.dart';
import 'package:satulemari/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:satulemari/features/request/presentation/bloc/request_bloc.dart';
import 'package:satulemari/features/request/presentation/widgets/donation_request_sheet.dart';
import 'package:satulemari/features/request/presentation/widgets/rental_request_sheet.dart';
import 'package:satulemari/shared/widgets/custom_button.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDetailPage extends StatefulWidget {
  const ItemDetailPage({super.key});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemId = ModalRoute.of(context)!.settings.arguments as String;

    return BlocProvider(
      create: (context) => sl<ItemDetailBloc>()..add(FetchItemDetail(itemId)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<ItemDetailBloc, ItemDetailState>(
          builder: (context, state) {
            if (state is ItemDetailLoading || state is ItemDetailInitial) {
              return const ItemDetailShimmer();
            }
            if (state is ItemDetailError) {
              return Center(child: Text(state.message));
            }
            if (state is ItemDetailLoaded) {
              return _buildLoadedContent(context, state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, ItemDetailLoaded state) {
    final item = state.item;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 350.0,
              pinned: true,
              backgroundColor: AppColors.primary,
              elevation: 0.5,
              title: const Text('Detail Item',
                  style: TextStyle(color: Colors.white)),
              leading: const BackButton(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                background: _buildImageCarousel(context, item.images),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(item),
                    _buildPrice(item), // <-- PERUBAHAN: Menampilkan harga
                    const Divider(height: 40, color: AppColors.divider),
                    _buildInfoSection(item),
                    const Divider(height: 40, color: AppColors.divider),
                    _buildDescription(item),
                    const Divider(height: 40, color: AppColors.divider),
                    _buildPartnerInfo(context, item),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomBar(context, state),
        )
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, ItemDetailLoaded state) {
    final item = state.item;
    final buttonState = state.buttonState;

    String buttonText;
    Color buttonColor;
    VoidCallback? onPressed;
    String? disabledReason;

    final isDonation = item.type.toLowerCase() == 'donation';

    switch (buttonState) {
      case ItemDetailButtonState.outOfStock:
        buttonText = "Stok Habis";
        buttonColor = AppColors.disabled;
        onPressed = null;
        disabledReason = "Maaf, barang ini sudah tidak tersedia saat ini.";
        break;
      case ItemDetailButtonState.pendingRequest:
        buttonText = "Permintaan Tertunda";
        buttonColor = AppColors.warning;
        onPressed = null;
        disabledReason =
            "Anda sudah memiliki permintaan untuk barang ini. Mohon tunggu konfirmasi.";
        break;
      case ItemDetailButtonState.quotaExceeded:
        buttonText = "Kuota Donasi Penuh";
        buttonColor = AppColors.premium;
        onPressed = null;
        disabledReason =
            "Anda telah mencapai batas 3x permintaan donasi minggu ini.";
        break;
      case ItemDetailButtonState.active:
      default:
        buttonText = isDonation ? "Ajukan Permintaan" : "Sewa Sekarang";
        buttonColor = isDonation ? AppColors.donation : AppColors.rental;
        onPressed = () => _showRequestSheet(context, item, isDonation);
        disabledReason = null;
        break;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: buttonText,
              onPressed: onPressed,
              backgroundColor: buttonColor,
              textColor: onPressed == null
                  ? Colors.white.withOpacity(0.8)
                  : Colors.white,
            ),
          ),
          if (disabledReason != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                disabledReason,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          ]
        ],
      ),
    );
  }

  void _showRequestSheet(
      BuildContext pageContext, ItemDetail item, bool isDonation) {
    final profileBloc = BlocProvider.of<ProfileBloc>(pageContext);

    showModalBottomSheet(
      context: pageContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return BlocProvider.value(
          value: profileBloc,
          child: BlocProvider(
            create: (context) => sl<RequestBloc>(),
            child: BlocListener<RequestBloc, RequestState>(
              listener: (context, state) {
                if (state is RequestSuccess) {
                  if (isDonation) {
                    context.read<ProfileBloc>().add(FetchProfileData());
                  }
                  ScaffoldMessenger.of(pageContext).showSnackBar(
                    const SnackBar(
                      content: Text('Permintaan berhasil dibuat!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  Navigator.of(pageContext).pushNamedAndRemoveUntil(
                    '/request-detail',
                    ModalRoute.withName('/main'),
                    arguments: state.requestDetail.id,
                  );
                } else if (state is RequestFailure) {
                  if (Navigator.of(modalContext).canPop()) {
                    Navigator.of(modalContext).pop();
                  }
                  ScaffoldMessenger.of(pageContext).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              child: isDonation
                  ? DonationRequestSheet(itemId: item.id)
                  : RentalRequestSheet(itemId: item.id),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageCarousel(BuildContext context, List<String> images) {
    if (images.isEmpty) {
      return Container(
          color: AppColors.surfaceVariant,
          child: const Center(
              child: Icon(Icons.inventory_2_outlined,
                  color: AppColors.disabled, size: 64)));
    }
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemCount: images.length,
          itemBuilder: (context, index) {
            final imageUrl = images[index];
            return GestureDetector(
              onTap: () {
                _openFullScreenViewer(context, images, index);
              },
              child: Hero(
                tag: imageUrl,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (c, u) =>
                      Container(color: AppColors.surfaceVariant),
                  errorWidget: (c, u, e) => const Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.disabled),
                ),
              ),
            );
          },
        ),
        if (images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: images.length,
                effect: const WormEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  activeDotColor: AppColors.primary,
                  dotColor: Colors.white70,
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 16,
          right: 16,
          child: GestureDetector(
            onTap: () {
              _openFullScreenViewer(context, images, _currentImageIndex);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fullscreen,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openFullScreenViewer(
      BuildContext context, List<String> images, int index) {
    Navigator.pushNamed(
      context,
      '/full-screen-image',
      arguments: FullScreenImageViewerArgs(
        imageUrls: images,
        initialIndex: index,
      ),
    );
  }

  Widget _buildHeader(ItemDetail item) {
    final tagColor = item.type.toLowerCase() == 'donation'
        ? AppColors.donation
        : AppColors.rental;
    final tagText = item.type.toLowerCase() == 'donation' ? 'Donasi' : 'Sewa';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(item.category.name.toUpperCase(),
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: tagColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(tagText,
                  style: TextStyle(
                      color: tagColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            )
          ],
        ),
        const SizedBox(height: 8),
        Text(item.name,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
      ],
    );
  }

  // Improved _buildPrice widget with better UI design

  Widget _buildPrice(ItemDetail item) {
    if (item.type.toLowerCase() == 'rental' &&
        item.price != null &&
        item.price! > 0) {
      final formattedPrice = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(item.price);

      return Container(
        margin: const EdgeInsets.only(top: 12.0, bottom: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.rental.withOpacity(0.1),
              AppColors.rental.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.rental.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.rental.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.attach_money_rounded,
                color: AppColors.rental,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Harga Sewa',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: formattedPrice,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.rental,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const TextSpan(
                          text: ' / hari',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInfoSection(ItemDetail item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Detail",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        const SizedBox(height: 16),
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16.0,
            runSpacing: 12.0,
            children: [
              _buildInfoChip("Ukuran", item.size ?? '-'),
              _buildInfoChip("Warna", item.color ?? '-'),
              _buildInfoChip("Kondisi", item.condition.toFormattedCondition()),
              _buildInfoChip("Stok", '${item.availableQuantity}'),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Column(
      children: [
        Text(label,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8)),
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildDescription(ItemDetail item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Deskripsi",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Text(item.description,
            style:
                const TextStyle(color: AppColors.textSecondary, height: 1.5)),
      ],
    );
  }

  Widget _buildPartnerInfo(BuildContext context, ItemDetail item) {
    final partner = item.partner;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Pemilik",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        const SizedBox(height: 16),
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.surfaceVariant,
              backgroundImage:
                  partner.photo != null ? NetworkImage(partner.photo!) : null,
              child: partner.photo == null
                  ? const Icon(Icons.person,
                      color: AppColors.disabled, size: 28)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(partner.fullName ?? partner.username,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(Icons.verified, color: AppColors.success, size: 14),
                      SizedBox(width: 4),
                      Text("Partner Terverifikasi",
                          style: TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if ((partner.phone != null && partner.phone!.isNotEmpty) ||
            (partner.latitude != null && partner.longitude != null)) ...[
          const SizedBox(height: 20),
          const Row(
            children: [
              Icon(Icons.phone_outlined,
                  color: AppColors.textSecondary, size: 16),
              SizedBox(width: 8),
              Text("Hubungi Pemilik",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (partner.phone != null && partner.phone!.isNotEmpty)
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: "Chat WhatsApp",
                    color: const Color(0xFF25D366),
                    onTap: () async {
                      final phone = partner.phone!.startsWith('0')
                          ? '62${partner.phone!.substring(1)}'
                          : partner.phone;
                      final waUrl = Uri.parse('https://wa.me/$phone');
                      if (await canLaunchUrl(waUrl)) {
                        await launchUrl(waUrl,
                            mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tidak dapat membuka WhatsApp.'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                  ),
                ),
              if ((partner.phone != null && partner.phone!.isNotEmpty) &&
                  (partner.latitude != null && partner.longitude != null))
                const SizedBox(width: 12),
              if (partner.latitude != null && partner.longitude != null)
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.location_on_outlined,
                    label: "Lihat Lokasi",
                    color: AppColors.primary,
                    onTap: () async {
                      final lat = partner.latitude;
                      final lng = partner.longitude;
                      final mapUrl = Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                      if (await canLaunchUrl(mapUrl)) {
                        await launchUrl(mapUrl);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tidak dapat membuka peta.'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
            color: color.withOpacity(0.05),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
