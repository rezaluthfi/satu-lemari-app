import 'package:json_annotation/json_annotation.dart';

part 'dashboard_stats_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class DashboardStatsModel {
  final int totalDonations;
  final int totalRentals;
  final int totalThrifting;
  final int activeItems;
  final int pendingRequests;
  final int completedRequests;
  final int weeklyQuotaUsed;
  final int weeklyQuotaRemaining;

  DashboardStatsModel({
    required this.totalDonations,
    required this.totalRentals,
    required this.totalThrifting,
    required this.activeItems,
    required this.pendingRequests,
    required this.completedRequests,
    required this.weeklyQuotaUsed,
    required this.weeklyQuotaRemaining,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsModelFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardStatsModelToJson(this);
}
