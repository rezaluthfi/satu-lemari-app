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
