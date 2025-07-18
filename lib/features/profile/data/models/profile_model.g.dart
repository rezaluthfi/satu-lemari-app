// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) => ProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      photo: json['photo'] as String?,
      description: json['description'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      weeklyDonationQuota: (json['weekly_donation_quota'] as num).toInt(),
      weeklyDonationUsed: (json['weekly_donation_used'] as num).toInt(),
      quotaResetDate: json['quota_reset_date'] as String,
    );

Map<String, dynamic> _$ProfileModelToJson(ProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'username': instance.username,
      'full_name': instance.fullName,
      'phone': instance.phone,
      'address': instance.address,
      'city': instance.city,
      'photo': instance.photo,
      'description': instance.description,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'weekly_donation_quota': instance.weeklyDonationQuota,
      'weekly_donation_used': instance.weeklyDonationUsed,
      'quota_reset_date': instance.quotaResetDate,
    };
