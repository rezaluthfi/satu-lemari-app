import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String? username;
  final String? fullName;
  final String? phone;
  final String? address;
  final String? city;
  final String? photo;
  final String? description;
  final String? role;
  final String createdAt;

  const User({
    required this.id,
    this.username,
    this.fullName,
    this.phone,
    this.address,
    this.city,
    this.photo,
    this.description,
    this.role,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? fullName,
    String? phone,
    String? address,
    String? city,
    String? photo,
    String? description,
    String? role,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      photo: photo ?? this.photo,
      description: description ?? this.description,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        fullName,
        phone,
        address,
        city,
        photo,
        description,
        role,
        createdAt
      ];
}
