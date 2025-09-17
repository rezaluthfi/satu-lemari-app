import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/core/di/injection.dart';
import 'package:satulemari/features/item_detail/domain/entities/item_detail.dart';
import 'package:satulemari/features/order/data/models/create_order_request_model.dart';
import 'package:satulemari/features/order/domain/entities/create_order_response.dart';
import 'package:satulemari/features/order/presentation/bloc/order_detail_bloc.dart';
import 'package:satulemari/features/profile/domain/entities/profile.dart';
import 'package:satulemari/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:satulemari/shared/widgets/custom_button.dart';
import 'package:satulemari/shared/widgets/custom_text_field.dart';

class CreateOrderPageArgs {
  final ItemDetail item;
  final String? requestId;
  CreateOrderPageArgs({required this.item, this.requestId});
}

class CreateOrderPage extends StatelessWidget {
  const CreateOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<OrderDetailBloc>(),
      child: BlocProvider.value(
        value: BlocProvider.of<ProfileBloc>(context),
        child: const _CreateOrderView(),
      ),
    );
  }
}

class _CreateOrderView extends StatefulWidget {
  const _CreateOrderView();
  @override
  State<_CreateOrderView> createState() => _CreateOrderViewState();
}

class _CreateOrderViewState extends State<_CreateOrderView> {
  String _shippingMethod = 'direct_cod';
  String? _paymentMethod;
  String _sellerDeliveryChoice = 'self_deliver';

  final _notesController = TextEditingController();

  // Variabel state yang tidak dibutuhkan lagi karena kalkulasi dilakukan backend
  // int _shippingFee = 15000;
  // int _totalAmount = 0;

  // Variabel ini tetap dibutuhkan untuk UI
  int? _itemPrice;
  int _quantity = 1;
  String? _itemType;
  ItemDetail? _item;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final args =
            ModalRoute.of(context)!.settings.arguments as CreateOrderPageArgs;
        setState(() {
          _item = args.item;
          _itemType = _item!.type;
          _itemPrice = _item!.price?.toInt() ?? 0;
          if (_itemType == 'thrifting') {
            _paymentMethod = 'qris';
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // Method ini tidak dibutuhkan lagi
  // void _updateTotalAmount() { ... }

  void _createOrder() {
    if (_item == null) return;

    final profileState = context.read<ProfileBloc>().state;

    if (profileState is ProfileLoaded) {
      if (_shippingMethod != 'pickup_warehouse' &&
          (profileState.profile.address == null ||
              profileState.profile.address!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Alamat pengiriman tidak boleh kosong untuk metode ini.'),
              backgroundColor: AppColors.error),
        );
        return;
      }
    }

    final args =
        ModalRoute.of(context)!.settings.arguments as CreateOrderPageArgs;

    final requestModel = CreateOrderRequestModel(
      itemId: args.item.id,
      requestId: args.requestId,
      quantity: _quantity,
      shippingMethod: _shippingMethod,
      paymentMethod: _paymentMethod,
      notes: _notesController.text.trim(),
      weightKg: 1.0,
      sellerDeliveryChoice:
          _shippingMethod == 'pickup_warehouse' ? _sellerDeliveryChoice : null,
    );

    context.read<OrderDetailBloc>().add(CreateOrderButtonPressed(requestModel));
  }

  String _formatCurrency(int amount) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
        .format(amount);
  }

  @override
  Widget build(BuildContext context) {
    if (_itemType == null || _item == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AppColors.background,
      body: BlocListener<OrderDetailBloc, OrderDetailState>(
        listener: (context, state) {
          if (state is OrderCreateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Pesanan berhasil dibuat! Lanjutkan pembayaran.'),
                  backgroundColor: AppColors.success),
            );
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              isDismissible: false,
              enableDrag: false,
              builder: (_) => PaymentSummarySheet(response: state.response),
            ).then((_) {
              Navigator.pushReplacementNamed(context, '/order-detail',
                  arguments: state.response.orderId);
            });
          }
          if (state is OrderDetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error),
            );
          }
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildItemCard(_item!),
                    const SizedBox(height: 24),
                    _buildAddressCard(),
                    const SizedBox(height: 24),
                    _buildShippingMethodCard(),
                    const SizedBox(height: 24),
                    _buildNotesCard(),
                  ],
                ),
              ),
            ),
            _buildBottomSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _buildItemCard(ItemDetail item) {
    final bool canDecrease = _quantity > 1;
    final bool canIncrease = _quantity < item.availableQuantity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Barang Pesanan'),
        const SizedBox(height: 12),
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: item.images.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: item.images.first,
                              fit: BoxFit.cover,
                              errorWidget: (c, e, s) => const Icon(Icons.error))
                          : Container(
                              color: AppColors.surfaceVariant,
                              child: const Icon(Icons.inventory_2_outlined)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.textPrimary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Text(_formatCurrency(_itemPrice ?? 0),
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Jumlah',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary)),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.remove,
                            size: 16,
                            color: canDecrease
                                ? AppColors.textPrimary
                                : AppColors.disabled,
                          ),
                          onPressed: canDecrease
                              ? () {
                                  setState(() => _quantity--);
                                }
                              : null,
                          visualDensity: VisualDensity.compact,
                        ),
                        Text(_quantity.toString(),
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                        IconButton(
                          icon: Icon(
                            Icons.add,
                            size: 16,
                            color: canIncrease
                                ? AppColors.textPrimary
                                : AppColors.disabled,
                          ),
                          onPressed: canIncrease
                              ? () {
                                  setState(() => _quantity++);
                                }
                              : null,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              if (!canIncrease)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Stok maksimal tercapai (${item.availableQuantity})',
                    style:
                        const TextStyle(color: AppColors.warning, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Alamat Pengiriman'),
        const SizedBox(height: 12),
        _buildCard(
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              String address = "Mohon atur alamat di profil Anda.";
              Profile? currentProfile;

              if (state is ProfileLoaded) {
                currentProfile = state.profile;
                if (currentProfile.address != null &&
                    currentProfile.address!.isNotEmpty) {
                  address = currentProfile.address!;
                }
              }

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    if (currentProfile != null) {
                      final result = await Navigator.pushNamed(
                          context, '/edit-profile',
                          arguments: currentProfile);
                      if (result == true && mounted) {
                        context.read<ProfileBloc>().add(FetchProfileData());
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Data profil belum siap, silakan coba lagi.'),
                            backgroundColor: AppColors.warning),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: AppColors.textSecondary, size: 20),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Dikirim ke",
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Text(address,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: AppColors.textHint),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShippingMethodCard() {
    final bool isRentalFlow = _itemType == 'rental';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Metode Pengiriman'),
        const SizedBox(height: 12),
        _buildCard(
          child: Column(
            children: [
              RadioListTile<String>(
                title: const Text('Diantar Penjual (COD)',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text(
                  'Koordinasi langsung dengan pemilik barang',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
                value: 'direct_cod',
                groupValue: _shippingMethod,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _shippingMethod = value);
                  }
                },
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
              ),
              const Divider(height: 1),
              Opacity(
                opacity: isRentalFlow ? 0.5 : 1.0,
                child: RadioListTile<String>(
                  title: const Text('Agen Aplikasi',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    isRentalFlow
                        ? 'Tidak tersedia untuk penyewaan'
                        : 'Pengiriman diurus oleh agen SatuLemari',
                    style: TextStyle(
                      color: isRentalFlow
                          ? AppColors.error
                          : AppColors.textSecondary,
                    ),
                  ),
                  value: 'app_agent',
                  groupValue: _shippingMethod,
                  onChanged: isRentalFlow
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _shippingMethod = value);
                          }
                        },
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                ),
              ),
              const Divider(height: 1),
              Opacity(
                opacity: isRentalFlow ? 0.5 : 1.0,
                child: RadioListTile<String>(
                  title: const Text('Ambil Sendiri (Pickup)',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    isRentalFlow
                        ? 'Tidak tersedia untuk penyewaan'
                        : 'Ambil barang di lokasi yang ditentukan',
                    style: TextStyle(
                      color: isRentalFlow
                          ? AppColors.error
                          : AppColors.textSecondary,
                    ),
                  ),
                  value: 'pickup_warehouse',
                  groupValue: _shippingMethod,
                  onChanged: isRentalFlow
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _shippingMethod = value);
                          }
                        },
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Catatan untuk Penjual (Opsional)'),
        const SizedBox(height: 12),
        CustomTextField(
          label: '',
          controller: _notesController,
          minLines: 3,
          maxLines: 5,
          hint: 'Contoh: Ukuran, warna, atau permintaan khusus lainnya...',
        ),
      ],
    );
  }

  Widget _buildBottomSummary() {
    if (_itemType == null) {
      return const SizedBox.shrink();
    }

    final buttonText = _itemType == 'donation'
        ? 'Konfirmasi Pengiriman Donasi'
        : 'Lanjutkan ke Pembayaran';

    return Container(
      padding: const EdgeInsets.all(20)
          .copyWith(bottom: MediaQuery.of(context).padding.bottom + 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_itemType != 'donation')
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Total harga akan ditampilkan di langkah selanjutnya.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          BlocBuilder<OrderDetailBloc, OrderDetailState>(
            builder: (context, state) {
              return CustomButton(
                text: buttonText,
                isLoading: state is OrderDetailLoading,
                onPressed: state is OrderDetailLoading ? null : _createOrder,
                width: double.infinity,
              );
            },
          ),
        ],
      ),
    );
  }
}

// Widget BottomSheet tetap sama
class PaymentSummarySheet extends StatelessWidget {
  final CreateOrderResponseEntity response;

  const PaymentSummarySheet({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(20).copyWith(
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Lanjutkan Pembayaran',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            response.totalAmount > 0
                ? 'Pindai QR Code untuk menyelesaikan pesanan'
                : 'Pesanan donasi Anda telah dikonfirmasi.',
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (response.qrisPayload != null && response.totalAmount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: QrImageView(
                  data: response.qrisPayload!,
                  version: QrVersions.auto,
                  size: 220.0,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          if (response.totalAmount > 0)
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer_outlined,
                      color: AppColors.error, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Bayar sebelum: ${DateFormat('dd MMM yyyy, HH:mm').format(response.expiresAt.toLocal())}',
                    style: const TextStyle(
                        color: AppColors.error, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Pembayaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                currencyFormat.format(response.totalAmount),
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Lihat Detail Pesanan',
            onPressed: () => Navigator.pop(context),
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
