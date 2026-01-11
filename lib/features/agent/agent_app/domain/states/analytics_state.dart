import '../../../../user/user_razorpay/domain/states/payment.dart';

class AnalyticsState {
  final int totalRevenue;
  final int todayRevenue;

  final int successCount;
  final int pendingCount;
  final int failedCount;

  final Map<DateTime, int> dailyRevenue;
  final Map<String, int> regionRevenue;

  final Map<String, int> genderCount;

  final List<Payment> filteredPayments;

  AnalyticsState({
    required this.totalRevenue,
    required this.todayRevenue,
    required this.successCount,
    required this.genderCount,

    required this.pendingCount,
    required this.failedCount,
    required this.dailyRevenue,
    required this.regionRevenue,
    this.filteredPayments = const [],
  });
}
