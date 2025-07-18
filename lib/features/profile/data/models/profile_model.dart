import 'package:json_annotation/json_annotation.dart';

part 'profile_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ProfileModel {
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

  ProfileModel({
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

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);
}
