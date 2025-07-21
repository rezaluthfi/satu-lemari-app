// File: features/request/presentation/widgets/rental_request_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/features/request/data/models/create_request_model.dart';
import 'package:satulemari/features/request/presentation/bloc/request_bloc.dart';
import 'package:satulemari/shared/widgets/custom_button.dart';
import 'package:satulemari/shared/widgets/custom_text_field.dart';

class RentalRequestSheet extends StatefulWidget {
  final String itemId;
  const RentalRequestSheet({super.key, required this.itemId});

  @override
  State<RentalRequestSheet> createState() => _RentalRequestSheetState();
}

class _RentalRequestSheetState extends State<RentalRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController(text: '1');
  final _pickupDateController = TextEditingController();
  final _returnDateController = TextEditingController();

  DateTime? _selectedPickupDate;
  DateTime? _selectedReturnDate;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      String? formatDate(DateTime? date) {
        if (date == null) return null;
        return DateFormat('yyyy-MM-dd').format(date);
      }

      final request = CreateRequestModel(
        itemId: widget.itemId,
        quantity: int.tryParse(_quantityController.text) ?? 1,
        pickupDate: formatDate(_selectedPickupDate),
        returnDate: formatDate(_selectedReturnDate),
      );
      context.read<RequestBloc>().add(SubmitRequest(request));
    }
  }

  Future<void> _selectDate(BuildContext context, bool isPickup) async {
    final now = DateTime.now();
    final initialPickerDate = isPickup
        ? (_selectedPickupDate ?? now)
        : (_selectedReturnDate ?? _selectedPickupDate ?? now);

    final firstDate = isPickup ? now : (_selectedPickupDate ?? now);
    final lastDate = now.add(const Duration(days: 365));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialPickerDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: isPickup ? 'Pilih Tanggal Ambil' : 'Pilih Tanggal Kembali',
    );

    if (pickedDate != null && mounted) {
      setState(() {
        if (isPickup) {
          _selectedPickupDate = pickedDate;
          _pickupDateController.text =
              DateFormat('dd MMMM yyyy').format(pickedDate);
          if (_selectedReturnDate != null &&
              pickedDate.isAfter(_selectedReturnDate!)) {
            _selectedReturnDate = null;
            _returnDateController.clear();
          }
        } else {
          if (_selectedPickupDate != null &&
              pickedDate.isBefore(_selectedPickupDate!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Tanggal kembali tidak boleh sebelum tanggal ambil.'),
                backgroundColor: AppColors.error,
              ),
            );
            return;
          }
          _selectedReturnDate = pickedDate;
          _returnDateController.text =
              DateFormat('dd MMMM yyyy').format(pickedDate);
        }
      });
      _formKey.currentState?.validate();
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _pickupDateController.dispose();
    _returnDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: BlocBuilder<RequestBloc, RequestState>(
        builder: (context, state) {
          // --- PERBAIKAN: Gunakan nama state yang benar ---
          final bool isLoading = state is RequestInProgress;

          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ajukan Permintaan Sewa',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                const Text('Isi detail penyewaan Anda di bawah ini.',
                    style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Jumlah',
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Jumlah tidak boleh kosong';
                    if (int.tryParse(value) == null || int.parse(value) <= 0)
                      return 'Jumlah tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Tanggal Ambil',
                  controller: _pickupDateController,
                  readOnly: true,
                  onTap: () => _selectDate(context, true),
                  prefixIcon: Icons.calendar_today,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Tanggal ambil tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Tanggal Kembali',
                  controller: _returnDateController,
                  readOnly: true,
                  onTap: () {
                    if (_selectedPickupDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Harap pilih tanggal ambil terlebih dahulu.'),
                            backgroundColor: AppColors.warning),
                      );
                      return;
                    }
                    _selectDate(context, false);
                  },
                  prefixIcon: Icons.calendar_today,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tanggal kembali tidak boleh kosong';
                    }
                    if (_selectedPickupDate != null &&
                        _selectedReturnDate != null &&
                        _selectedReturnDate!.isBefore(_selectedPickupDate!)) {
                      return 'Tanggal kembali tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Kirim Permintaan',
                  onPressed: isLoading ? null : _submit,
                  width: double.infinity,
                  isLoading: isLoading,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
