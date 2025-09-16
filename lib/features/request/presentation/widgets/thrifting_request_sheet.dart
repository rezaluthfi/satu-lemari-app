import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:satulemari/features/request/data/models/create_request_model.dart';
import 'package:satulemari/features/request/presentation/bloc/request_bloc.dart';
import 'package:satulemari/shared/widgets/custom_button.dart';
import 'package:satulemari/shared/widgets/custom_text_field.dart';

class ThriftingPurchaseSheet extends StatefulWidget {
  final String itemId;
  const ThriftingPurchaseSheet({super.key, required this.itemId});

  @override
  State<ThriftingPurchaseSheet> createState() => _ThriftingPurchaseSheetState();
}

class _ThriftingPurchaseSheetState extends State<ThriftingPurchaseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController(text: '1');
  // <-- PERUBAHAN: Mengganti nama controller agar sesuai dengan tujuan
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final request = CreateRequestModel(
        itemId: widget.itemId,
        quantity: int.tryParse(_quantityController.text) ?? 1,
        // <-- PERUBAHAN: Menggunakan 'reason' untuk menyimpan catatan, sesuai model
        reason: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      context.read<RequestBloc>().add(SubmitRequest(request));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileBloc>().state;
    String deliveryAddress = 'Alamat belum diatur.';
    if (profileState is ProfileLoaded &&
        profileState.profile.address != null &&
        profileState.profile.address!.isNotEmpty) {
      deliveryAddress = profileState.profile.address!;
    } else if (profileState is ProfileLoading) {
      deliveryAddress = 'Memuat alamat...';
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: BlocBuilder<RequestBloc, RequestState>(
        builder: (context, state) {
          final bool isLoading = state is RequestInProgress;

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              // <-- TAMBAHAN: Dibungkus dengan SingleChildScrollView
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Konfirmasi Pembelian',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  const Text(
                      'Periksa kembali detail pembelian Anda sebelum melanjutkan.',
                      style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  _buildInfoSection(
                    icon: Icons.location_on_outlined,
                    title: 'Alamat Pengiriman',
                    content: deliveryAddress,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Jumlah',
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.shopping_cart_checkout_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jumlah tidak boleh kosong';
                      }
                      final quantity = int.tryParse(value);
                      if (quantity == null || quantity <= 0) {
                        return 'Jumlah tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Catatan untuk Penjual (Opsional)',
                    controller: _notesController,
                    keyboardType: TextInputType.text,
                    prefixIcon: Icons.note_alt_outlined,
                    maxLines: 2,
                    // <-- PERUBAHAN: Menggunakan 'hint' bukan 'hintText'
                    hint: 'Contoh: Ukuran, preferensi warna, dll.',
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Beli Sekarang',
                    onPressed: isLoading ? null : _submit,
                    width: double.infinity,
                    isLoading: isLoading,
                    backgroundColor: AppColors.thrifting,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
