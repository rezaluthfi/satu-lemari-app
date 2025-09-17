import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/core/di/injection.dart';
import 'package:satulemari/features/item_detail/domain/entities/item_detail.dart';
import 'package:satulemari/features/order/data/models/create_order_request_model.dart';
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

  int? _itemPrice;
  int _shippingFee = 15000;
  int _totalAmount = 0;
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
          _updateTotalAmount();
        });
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _updateTotalAmount() {
    if (_itemPrice == null) return;
    setState(() {
      final subtotal = _itemPrice! * _quantity;
      final currentShippingFee =
          _shippingMethod == 'pickup_warehouse' ? 0 : _shippingFee;

      if (_itemType == 'donation') {
        _totalAmount = 0;
      } else {
        _totalAmount = subtotal + currentShippingFee;
      }
    });
  }

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
                  content: Text('Pesanan berhasil dibuat!'),
                  backgroundColor: AppColors.success),
            );
            Navigator.pushReplacementNamed(context, '/order-detail',
                arguments: state.newOrderId);
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
    // Variabel boolean untuk status tombol
    final bool canDecrease = _quantity > 1;
    final bool canIncrease = _quantity < item.availableQuantity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Barang Pesanan'),
        const SizedBox(height: 12),
        _buildCard(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.end, // <-- Untuk alignment pesan error
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
                            // <-- PERBAIKAN: Warna dinamis
                            color: canDecrease
                                ? AppColors.textPrimary
                                : AppColors.disabled,
                          ),
                          onPressed: canDecrease
                              ? () {
                                  setState(() {
                                    _quantity--;
                                    _updateTotalAmount();
                                  });
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
                            // <-- PERBAIKAN: Warna dinamis
                            color: canIncrease
                                ? AppColors.textPrimary
                                : AppColors.disabled,
                          ),
                          onPressed: canIncrease
                              ? () {
                                  setState(() {
                                    _quantity++;
                                    _updateTotalAmount();
                                  });
                                }
                              : null,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              // <-- PERBAIKAN: Posisi pesan stok
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
    // Tentukan apakah kita berada di alur rental
    final bool isRentalFlow = _itemType == 'rental';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Metode Pengiriman'),
        const SizedBox(height: 12),
        _buildCard(
          child: Column(
            children: [
              // Opsi 1: Diantar Penjual (COD)
              RadioListTile<String>(
                title: const Text('Diantar Penjual (COD)',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text(
                  'Koordinasi langsung dengan pemilik barang',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                value: 'direct_cod',
                groupValue: _shippingMethod,
                // Selalu aktif
                onChanged: (value) {
                  if (value != null)
                    setState(() {
                      _shippingMethod = value;
                      _updateTotalAmount();
                    });
                },
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
              ),
              const Divider(height: 1),

              // Opsi 2: Agen Aplikasi
              Opacity(
                // Buat terlihat "mati" jika ini alur rental
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
                  // Nonaktifkan jika ini alur rental
                  onChanged: isRentalFlow
                      ? null
                      : (value) {
                          if (value != null)
                            setState(() {
                              _shippingMethod = value;
                              _updateTotalAmount();
                            });
                        },
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                ),
              ),
              const Divider(height: 1),

              // Opsi 3: Ambil Sendiri (Pickup)
              Opacity(
                // Buat terlihat "mati" jika ini alur rental
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
                  // Nonaktifkan jika ini alur rental
                  onChanged: isRentalFlow
                      ? null
                      : (value) {
                          if (value != null)
                            setState(() {
                              _shippingMethod = value;
                              _updateTotalAmount();
                            });
                        },
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                ),
              ),

              // Opsi untuk penjual tetap muncul jika 'pickup_warehouse' dipilih (tidak akan terjadi di alur rental)
              if (_shippingMethod == 'pickup_warehouse')
                _buildSellerChoiceSection(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSellerChoiceSection() {
    return Container(
      margin: const EdgeInsets.only(top: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              'Opsi untuk Penjual:',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ),
          RadioListTile<String>(
            title: const Text('Penjual Antar Sendiri',
                style: TextStyle(fontSize: 14)),
            value: 'self_deliver',
            groupValue: _sellerDeliveryChoice,
            onChanged: (value) {
              if (value != null) setState(() => _sellerDeliveryChoice = value);
            },
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.primary,
          ),
          RadioListTile<String>(
            title: const Text('Agen Aplikasi yang Ambil',
                style: TextStyle(fontSize: 14)),
            value: 'agent_pickup',
            groupValue: _sellerDeliveryChoice,
            onChanged: (value) {
              if (value != null) setState(() => _sellerDeliveryChoice = value);
            },
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.primary,
          ),
        ],
      ),
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

    if (_itemType == 'donation') {
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
        child: BlocBuilder<OrderDetailBloc, OrderDetailState>(
          builder: (context, state) {
            return CustomButton(
              text: 'Konfirmasi Pengiriman Donasi',
              isLoading: state is OrderDetailLoading,
              onPressed: state is OrderDetailLoading ? null : _createOrder,
              width: double.infinity,
            );
          },
        ),
      );
    }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal Barang',
                  style: TextStyle(color: AppColors.textSecondary)),
              Text(_formatCurrency((_itemPrice ?? 0) * _quantity),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ongkos Kirim',
                  style: TextStyle(color: AppColors.textSecondary)),
              Text(
                  _shippingMethod == 'pickup_warehouse'
                      ? 'Rp0'
                      : _formatCurrency(_shippingFee),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.textPrimary)),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Pembayaran',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.textPrimary)),
              Text(_formatCurrency(_totalAmount),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 20),
          BlocBuilder<OrderDetailBloc, OrderDetailState>(
            builder: (context, state) {
              return CustomButton(
                text: 'Buat Pesanan & Bayar',
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
