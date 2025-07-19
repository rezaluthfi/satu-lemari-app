import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/core/di/injection.dart';
import 'package:satulemari/features/item_detail/domain/entities/item_detail.dart';
import 'package:satulemari/features/item_detail/presentation/bloc/item_detail_bloc.dart';
import 'package:satulemari/features/item_detail/presentation/pages/full_screen_image_viewer.dart';
import 'package:satulemari/features/item_detail/presentation/widgets/item_detail_shimmer.dart';
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

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              sl<ItemDetailBloc>()..add(FetchItemDetail(itemId)),
        ),
        BlocProvider(
          create: (context) => sl<RequestBloc>(),
        ),
      ],
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
              return _buildLoadedContent(context, state.item);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, ItemDetail item) {
    return BlocListener<RequestBloc, RequestState>(
      listener: (context, state) {
        if (state is RequestFailure) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message), backgroundColor: AppColors.error));
        }
        if (state is RequestSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Permintaan berhasil dibuat!'),
              backgroundColor: AppColors.success));

          Navigator.of(context).pushNamedAndRemoveUntil(
            '/request-detail',
            ModalRoute.withName('/main'),
            arguments: state.requestDetail.id,
          );
        }
      },
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 350.0,
                pinned: true,
                backgroundColor: AppColors.background,
                elevation: 0.5,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const BackButton(color: Colors.white),
                  ),
                ),
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
            child: _buildBottomBar(context, item),
          )
        ],
      ),
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
          children: [
            Text(item.category.name.toUpperCase(),
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5)),
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

  Widget _buildInfoSection(ItemDetail item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Detail",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoChip("Ukuran", item.size ?? '-'),
            _buildInfoChip("Warna", item.color ?? '-'),
            _buildInfoChip("Kondisi", item.condition),
            _buildInfoChip("Stok", '${item.availableQuantity}'),
          ],
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8)),
          child:
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  Widget _buildDescription(ItemDetail item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Deskripsi",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.surfaceVariant,
              backgroundImage:
                  partner.photo != null ? NetworkImage(partner.photo!) : null,
              child: partner.photo == null
                  ? const Icon(Icons.person, color: AppColors.disabled)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(partner.fullName ?? partner.username,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Text("Partner Terverifikasi",
                      style: TextStyle(color: AppColors.success, fontSize: 12)),
                ],
              ),
            ),
            if (partner.phone != null && partner.phone!.isNotEmpty)
              IconButton(
                onPressed: () async {
                  final phone = partner.phone!.startsWith('0')
                      ? '62${partner.phone!.substring(1)}'
                      : partner.phone;
                  final waUrl = Uri.parse('https://wa.me/$phone');
                  if (await canLaunchUrl(waUrl)) {
                    await launchUrl(waUrl,
                        mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Tidak dapat membuka WhatsApp.')));
                  }
                },
                icon: const Icon(Icons.chat_bubble_outline,
                    color: AppColors.primary),
                tooltip: 'Chat via WhatsApp',
              ),
            // --- PERBAIKI LOGIKA PETA DI SINI ---
            if (partner.latitude != null && partner.longitude != null)
              IconButton(
                onPressed: () async {
                  final lat = partner.latitude;
                  final lng = partner.longitude;
                  final mapUrl = Uri.parse(
                      'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                  if (await canLaunchUrl(mapUrl)) {
                    await launchUrl(mapUrl);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Tidak dapat membuka peta.')));
                  }
                },
                icon: const Icon(Icons.map_outlined, color: AppColors.primary),
                tooltip: 'Lihat Lokasi',
              ),
          ],
        )
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, ItemDetail item) {
    final isDonation = item.type.toLowerCase() == 'donation';
    final buttonText = isDonation ? "Ajukan Permintaan" : "Sewa Sekarang";
    final buttonColor = isDonation ? AppColors.donation : AppColors.rental;

    return Container(
      padding: const EdgeInsets.all(16).copyWith(top: 12),
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
      child: CustomButton(
        text: buttonText,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            // backgroundColor: Colors.transparent, // <-- Biarkan transparan, karena warna diatur di dalam sheet
            shape: const RoundedRectangleBorder(
              // <-- Tambahkan shape untuk border radius
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (_) => BlocProvider.value(
              // Teruskan instance RequestBloc dari halaman ini ke bottom sheet
              value: BlocProvider.of<RequestBloc>(context),
              child: isDonation
                  ? DonationRequestSheet(itemId: item.id)
                  : RentalRequestSheet(itemId: item.id),
            ),
          );
        },
        backgroundColor: buttonColor,
      ),
    );
  }
}
