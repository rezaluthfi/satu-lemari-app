import 'package:satulemari/features/auth/domain/entities/user.dart';

// Model for user data
class UserModel extends User {
  const UserModel({
    required super.id,
    super.username,
    super.fullName,
    super.phone,
    super.address,
    super.city,
    super.photo,
    super.description,
    super.role,
    required super.createdAt,
  });

  // Factory constructor for JSON parsing
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String?,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      photo: json['photo'] as String?,
      description: json['description'] as String?,
      role: json['role'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'phone': phone,
      'address': address,
      'city': city,
      'photo': photo,
      'description': description,
      'role': role,
      'created_at': createdAt,
    };
  }
}
