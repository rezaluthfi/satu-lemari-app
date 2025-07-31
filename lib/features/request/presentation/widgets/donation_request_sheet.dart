import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/core/utils/validators.dart';
import 'package:satulemari/features/request/data/models/create_request_model.dart';
import 'package:satulemari/features/request/presentation/bloc/request_bloc.dart';
import 'package:satulemari/shared/widgets/custom_button.dart';
import 'package:satulemari/shared/widgets/custom_text_field.dart';

class DonationRequestSheet extends StatefulWidget {
  final String itemId;
  const DonationRequestSheet({super.key, required this.itemId});

  @override
  State<DonationRequestSheet> createState() => _DonationRequestSheetState();
}

class _DonationRequestSheetState extends State<DonationRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final request = CreateRequestModel(
        itemId: widget.itemId,
        quantity: 1,
        reason: _reasonController.text.trim(),
      );
      context.read<RequestBloc>().add(SubmitRequest(request));
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
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
      child: Form(
        key: _formKey,
        child: BlocBuilder<RequestBloc, RequestState>(
          builder: (context, state) {
            final bool isLoading = state is RequestInProgress;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ajukan Permintaan Donasi',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                const Text(
                    'Tuliskan alasan mengapa Anda membutuhkan barang ini.',
                    style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Alasan Permintaan', // Label yang lebih jelas
                  controller: _reasonController,
                  maxLines: 4,
                  hint: 'Contoh: Untuk wawancara kerja...',
                  validator: (value) =>
                      Validators.validateRequired(value, 'Alasan'),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Kirim Permintaan',
                  onPressed: isLoading ? null : _submit,
                  width: double.infinity,
                  isLoading: isLoading,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
