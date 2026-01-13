import '../../../../user/user_razorpay/domain/states/payment.dart';

class AnalyticsState {
  final int totalRevenue;
  final int todayRevenue;

  final int successCount;
  final int pendingCount;
  final int failedCount;
  final int maleRevenue;
  final int femaleRevenue;
  final int otherRevenue;

  final Map<DateTime, int> dailyRevenue;
  final Map<String, int> regionRevenue;

  final Map<String, int> genderCount;

  final List<Payment> filteredPayments;

  final Map<String, int> religionRevenue;
  final Map<String, int> casteRevenue;
  final Map<String, int> districtRevenue;

  final Map<String, int> genderRevenue;

  AnalyticsState({
    this.genderRevenue = const {},
    this.districtRevenue = const {},
    

    required this.maleRevenue,
    required this.femaleRevenue,
    required this.otherRevenue,
    required this.totalRevenue,

    required this.religionRevenue,
    required this.casteRevenue,

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
