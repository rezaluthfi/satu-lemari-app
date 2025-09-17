// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardStatsModel _$DashboardStatsModelFromJson(Map<String, dynamic> json) =>
    DashboardStatsModel(
      totalDonations: (json['total_donations'] as num).toInt(),
      totalRentals: (json['total_rentals'] as num).toInt(),
      totalThrifting: (json['total_thrifting'] as num).toInt(),
      activeItems: (json['active_items'] as num).toInt(),
      pendingRequests: (json['pending_requests'] as num).toInt(),
      completedRequests: (json['completed_requests'] as num).toInt(),
      weeklyQuotaUsed: (json['weekly_quota_used'] as num).toInt(),
      weeklyQuotaRemaining: (json['weekly_quota_remaining'] as num).toInt(),
    );

Map<String, dynamic> _$DashboardStatsModelToJson(
        DashboardStatsModel instance) =>
    <String, dynamic>{
      'total_donations': instance.totalDonations,
      'total_rentals': instance.totalRentals,
      'total_thrifting': instance.totalThrifting,
      'active_items': instance.activeItems,
      'pending_requests': instance.pendingRequests,
      'completed_requests': instance.completedRequests,
      'weekly_quota_used': instance.weeklyQuotaUsed,
      'weekly_quota_remaining': instance.weeklyQuotaRemaining,
    };
