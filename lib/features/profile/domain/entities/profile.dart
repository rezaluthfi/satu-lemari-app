import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String id;
  final String email;
  final String username;
  final String? fullName;
  final String? phone;
  final String? address;
  final String? city;
  final String? photo;
  final String? description;
  final double? latitude;
  final double? longitude;
  final int weeklyDonationQuota;
  final int weeklyDonationUsed;
  final String quotaResetDate;

  const Profile({
    required this.id,
    required this.email,
    required this.username,
    this.fullName,
    this.phone,
    this.address,
    this.city,
    this.photo,
    this.description,
    this.latitude,
    this.longitude,
    required this.weeklyDonationQuota,
    required this.weeklyDonationUsed,
    required this.quotaResetDate,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        username,
        fullName,
        phone,
        address,
        city,
        photo,
        description,
        latitude,
        longitude,
        weeklyDonationQuota,
        weeklyDonationUsed,
        quotaResetDate
      ];

  Profile copyWith({
    String? id,
    String? email,
    String? username,
    String? fullName,
    String? phone,
    String? address,
    String? city,
    String? photo,
    String? description,
    double? latitude,
    double? longitude,
    int? weeklyDonationQuota,
    int? weeklyDonationUsed,
    String? quotaResetDate,
  }) {
    return Profile(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      photo: photo ?? this.photo,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      weeklyDonationQuota: weeklyDonationQuota ?? this.weeklyDonationQuota,
      weeklyDonationUsed: weeklyDonationUsed ?? this.weeklyDonationUsed,
      quotaResetDate: quotaResetDate ?? this.quotaResetDate,
    );
  }
}
