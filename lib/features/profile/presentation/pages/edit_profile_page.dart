import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/features/profile/data/models/update_profile_request.dart';
import 'package:satulemari/features/profile/domain/entities/profile.dart';
import 'package:satulemari/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:satulemari/features/profile/presentation/pages/location_picker_page.dart';
import 'package:satulemari/shared/widgets/custom_button.dart';
import 'package:satulemari/shared/widgets/custom_text_field.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _descriptionController;

  XFile? _newImageFile; // State untuk menyimpan file gambar yang dipilih
  double? _latitude;
  double? _longitude;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final profile = ModalRoute.of(context)!.settings.arguments as Profile;
      _fullNameController.text = profile.fullName ?? '';
      _phoneController.text = profile.phone ?? '';
      _addressController.text = profile.address ?? '';
      _cityController.text = profile.city ?? '';
      _descriptionController.text = profile.description ?? '';
      _latitude = profile.latitude;
      _longitude = profile.longitude;
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSavePressed() {
    if (_formKey.currentState!.validate()) {
      String? textOrNull(TextEditingController controller) {
        final text = controller.text.trim();
        return text.isEmpty ? null : text;
      }

      final request = UpdateProfileRequest(
        fullName: textOrNull(_fullNameController),
        phone: textOrNull(_phoneController),
        address: textOrNull(_addressController),
        city: textOrNull(_cityController),
        description: textOrNull(_descriptionController),
        photoFile: _newImageFile, // Kirim file gambar
        latitude: _latitude,
        longitude: _longitude,
      );
      context.read<ProfileBloc>().add(UpdateProfileButtonPressed(request));
    }
  }

  Future<void> _openLocationPicker() async {
    final initialLocation = (_latitude != null && _longitude != null)
        ? LatLng(_latitude!, _longitude!)
        : null;

    final result = await Navigator.push<LocationResult>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            LocationPickerPage(initialLocation: initialLocation),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _addressController.text = result.address;
        _cityController.text = result.city;
        _latitude = result.coordinates.latitude;
        _longitude = result.coordinates.longitude;
      });
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.of(context).pop();
                _pickAndCropImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickAndCropImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndCropImage(ImageSource source) async {
    final picker = ImagePicker();
    final cropper = ImageCropper();

    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    final croppedFile = await cropper.cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 70,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Potong Gambar',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true),
        IOSUiSettings(title: 'Potong Gambar', aspectRatioLockEnabled: true),
      ],
    );

    if (croppedFile != null && mounted) {
      setState(() {
        _newImageFile = XFile(croppedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ModalRoute.of(context)!.settings.arguments as Profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Profil berhasil diperbarui!'),
                backgroundColor: AppColors.success));
            Navigator.of(context).pop(true);
          }
          if (state is ProfileUpdateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error));
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.surfaceVariant,
                      backgroundImage: _newImageFile != null
                          ? FileImage(File(_newImageFile!.path))
                              as ImageProvider
                          : (profile.photo != null && profile.photo!.isNotEmpty
                              ? CachedNetworkImageProvider(profile.photo!)
                              : null),
                      child: _newImageFile == null &&
                              (profile.photo == null || profile.photo!.isEmpty)
                          ? const Icon(Icons.person,
                              size: 50, color: AppColors.disabled)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _showImageSourceActionSheet(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                              color: AppColors.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                  label: 'Nama Lengkap',
                  controller: _fullNameController,
                  validator: (value) =>
                      value!.isEmpty ? 'Nama tidak boleh kosong' : null),
              const SizedBox(height: 16),
              CustomTextField(
                  label: 'Nomor Telepon',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Alamat Lengkap',
                controller: _addressController,
                minLines: 3,
                maxLines: null,
                hint: 'Alamat lengkap akan diisi otomatis dari peta',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                  label: 'Kota',
                  controller: _cityController,
                  hint: 'Kota akan diisi otomatis dari peta'),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Pilih Lokasi di Peta',
                onPressed: _openLocationPicker,
                type: ButtonType.outline,
                icon: Icons.map_outlined,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                  label: 'Deskripsi Singkat',
                  controller: _descriptionController,
                  maxLines: 4),
              const SizedBox(height: 32),
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  return CustomButton(
                    text: 'Simpan Perubahan',
                    onPressed: _onSavePressed,
                    isLoading: state is ProfileUpdateInProgress,
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
