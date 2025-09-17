import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/core/utils/validators.dart';
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

class _EditProfilePageState extends State<EditProfilePage>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Profile? _profile;

  final ImagePicker _picker = ImagePicker();
  XFile? _newImageFile;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)!.settings.arguments;
      if (arguments is Profile) {
        if (mounted) {
          setState(() {
            _profile = arguments;
            _usernameController.text = _profile!.username;
            _fullNameController.text = _profile!.fullName ?? '';
            _phoneController.text = _profile!.phone ?? '';
            _addressController.text = _profile!.address ?? '';
            _cityController.text = _profile!.city ?? '';
            _descriptionController.text = _profile!.description ?? '';
            _latitude = _profile!.latitude;
            _longitude = _profile!.longitude;
          });
        }
      } else {
        // Handle jika tidak ada argumen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Gagal memuat data profil.'),
              backgroundColor: AppColors.error),
        );
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _retrieveLostData();
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      if (mounted) {
        _cropImage(response.file!);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _usernameController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSavePressed() {
    if (_profile == null) return; // Guard clause

    if (_formKey.currentState!.validate()) {
      String? textOrNull(TextEditingController controller) {
        final text = controller.text.trim();
        return text.isEmpty ? null : text;
      }

      final request = UpdateProfileRequest(
        // Tidak perlu mengirim ID di body request, backend sudah tahu dari auth
        username: textOrNull(_usernameController),
        fullName: textOrNull(_fullNameController),
        phone: textOrNull(_phoneController),
        address: textOrNull(_addressController),
        city: textOrNull(_cityController),
        description: textOrNull(_descriptionController),
        photoFile: _newImageFile,
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
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null || !mounted) return;

    _cropImage(pickedFile);
  }

  Future<void> _cropImage(XFile imageFile) async {
    final cropper = ImageCropper();
    final croppedFile = await cropper.cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 70,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Potong Gambar',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true),
        IOSUiSettings(
            title: 'Potong Gambar',
            aspectRatioLockEnabled: true,
            aspectRatioPickerButtonHidden: true,
            resetAspectRatioEnabled: false),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: _profile == null
          ? const Center(child: CircularProgressIndicator())
          : BlocListener<ProfileBloc, ProfileState>(
              listener: (context, state) {
                if (state is ProfileUpdateSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Profil berhasil diperbarui!'),
                      backgroundColor: AppColors.success));
                  Navigator.of(context).pop(true);
                } else if (state is ProfileUpdateFailure) {
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
                                : (_profile!.photo != null &&
                                        _profile!.photo!.isNotEmpty
                                    ? CachedNetworkImageProvider(
                                        _profile!.photo!)
                                    : null),
                            child: _newImageFile == null &&
                                    (_profile!.photo == null ||
                                        _profile!.photo!.isEmpty)
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
                                    color: AppColors.primary,
                                    shape: BoxShape.circle),
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
                      label: 'Username',
                      controller: _usernameController,
                      validator: (value) =>
                          Validators.validateRequired(value, 'Username'),
                      hint: 'Contoh: john.doe',
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Email',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Text(
                        _profile!.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Email tidak dapat diubah.',
                      style: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                        label: 'Nama Lengkap',
                        controller: _fullNameController,
                        validator: (value) =>
                            Validators.validateRequired(value, 'Nama Lengkap')),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Nomor Telepon',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: Validators.validatePhoneNumber,
                    ),
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
                      icon: const Icon(Icons.map_outlined),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                        label: 'Deskripsi Singkat',
                        controller: _descriptionController,
                        maxLines: 4),
                    const SizedBox(height: 32),
                    BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (context, state) {
                        final isLoading = state is ProfileUpdateInProgress;
                        return CustomButton(
                          text: 'Simpan Perubahan',
                          onPressed: isLoading ? null : _onSavePressed,
                          isLoading: isLoading,
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
