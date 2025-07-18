import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int totalDonations;
  final int totalRentals;
  final int activeItems;
  final int pendingRequests;
  final int completedRequests;
  final int weeklyQuotaUsed;
  final int weeklyQuotaRemaining;

  const DashboardStats({
    required this.totalDonations,
    required this.totalRentals,
    required this.activeItems,
    required this.pendingRequests,
    required this.completedRequests,
    required this.weeklyQuotaUsed,
    required this.weeklyQuotaRemaining,
  });

  @override
  List<Object?> get props => [
        totalDonations,
        totalRentals,
        activeItems,
        pendingRequests,
        completedRequests,
        weeklyQuotaUsed,
        weeklyQuotaRemaining
      ];
}
