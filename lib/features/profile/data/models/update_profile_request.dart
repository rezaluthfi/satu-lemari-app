import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProfileRequest extends Equatable {
  final String? fullName;
  final String? phone;
  final String? address;
  final String? city;
  final XFile? photoFile; // Mengirim file, bukan URL
  final String? description;
  final double? latitude;
  final double? longitude;
  const UpdateProfileRequest({
    this.fullName,
    this.phone,
    this.address,
    this.city,
    this.photoFile,
    this.description,
    this.latitude,
    this.longitude,
  });
  @override
  List<Object?> get props => [
        fullName,
        phone,
        address,
        city,
        photoFile,
        description,
        latitude,
        longitude
      ];
}
