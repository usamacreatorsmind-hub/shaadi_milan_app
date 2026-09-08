
import '../screens/agen_profile.screen.dart';
import '../../../../../core/filters/revenue_filter_controller.dart';
import '../../domain/states/analytics_state.dart';
import 'user_nofier.dart';
import '../../../../user/user_razorpay/domain/states/payment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyticsProvider =
    Provider.family<AsyncValue<AnalyticsState>, String>((ref, agentId) {
      final paymentsAsync = ref.watch(usersPaymentsNotifierProvider);
      final agentAsync = ref.watch(agentProvider(agentId));
      final filter = ref.watch(revenueFilterProvider);

      // Combine both async values
      if (paymentsAsync is AsyncLoading || agentAsync is AsyncLoading) {
        return const AsyncValue.loading();
      }

      if (paymentsAsync is AsyncError) {
        return AsyncValue.error(
          paymentsAsync.error!,
          paymentsAsync.stackTrace!,
        );
      }
      if (agentAsync is AsyncError) {
        return AsyncValue.error(agentAsync.error!, agentAsync.stackTrace!);
      }

      final payments = paymentsAsync.value ?? [];
      final agent = agentAsync.value!;

      int totalRevenue = 0;
      int todayRevenue = 0;

      int success = 0;
      int pending = 0;
      int failed = 0;

      final Map<DateTime, int> dailyRevenue = {};
      final Map<String, int> regionRevenue = {};
      final Map<String, int> religionRevenue = {};
      final Map<String, int> casteRevenue = {};
      int maleRevenue = 0;
      int femaleRevenue = 0;
      int otherRevenue = 0;
      double totalCommission = 0;

      final now = DateTime.now();
      
      // 1. Filter Payments
      // ... (keeping existing filter logic)
      final filteredPayments =
          payments.where((p) {
            if (p == null) return false;

            // Region Filter
            if (filter.state.isNotEmpty && p.region != filter.state) {
              return false;
            }

            // District Filter
            if (filter.city.isNotEmpty && p.district != filter.city) {
              return false;
            }

            // Religion Filter
            if (filter.religion.isNotEmpty && p.religion != filter.religion) {
              return false;
            }

            // Caste Filter
            if (filter.caste.isNotEmpty && p.caste != filter.caste) {
              return false;
            }

            // Gender Filter
            if (filter.gender.isNotEmpty && p.gender != filter.gender) {
              return false;
            }

            // Date Range Filter
            // Adding 1 day to endDate to include the full end day
            if (p.createdAt.isBefore(filter.startDate) ||
                p.createdAt.isAfter(
                  filter.endDate.add(const Duration(days: 1)),
                )) {
              return false;
            }

            return true;
          }).toList();

      // 2. Calculate Analytics on Filtered Data
      for (final p in filteredPayments) {
        if (p == null) continue;

        final status = p.status.toUpperCase();
        final date = DateTime(
          p.createdAt.year,
          p.createdAt.month,
          p.createdAt.day,
        );

        if (status == 'SUCCESS') {
          success++;
          totalRevenue += p.amount;

          // Use stored commission if available, fallback to current rate for legacy data
          if (p.agentCommission > 0) {
            totalCommission += p.agentCommission;
          } else {
            totalCommission += agent.calculateCommission(p.amount.toDouble());
          }

          if (date == DateTime(now.year, now.month, now.day)) {
            todayRevenue += p.amount;
          }

          dailyRevenue[date] = (dailyRevenue[date] ?? 0) + p.amount;
          if (p.region != null && p.region!.isNotEmpty) {
            regionRevenue[p.region!] =
                (regionRevenue[p.region] ?? 0) + p.amount;
          }

          if (p.religion.isNotEmpty) {
            religionRevenue[p.religion] =
                (religionRevenue[p.religion] ?? 0) + p.amount;
          }

          if (p.caste.isNotEmpty) {
            casteRevenue[p.caste] = (casteRevenue[p.caste] ?? 0) + p.amount;
          }
        } else if (status == 'PENDING') {
          pending++;
        } else if (status == 'FAILED') {
          failed++;
        }
      }

      return AsyncValue.data(
        AnalyticsState(
          maleRevenue: maleRevenue,
          femaleRevenue: femaleRevenue,
          otherRevenue: otherRevenue,
          totalCommission: totalCommission,
          genderRevenue: {
            'Male': maleRevenue,
            'Female': femaleRevenue,
            'Other': otherRevenue,
          },
          districtRevenue: {},
          genderCount: {},
          totalRevenue: totalRevenue,
          todayRevenue: todayRevenue,
          successCount: success,
          pendingCount: pending,
          failedCount: failed,
          dailyRevenue: dailyRevenue,
          regionRevenue: regionRevenue,
          religionRevenue: religionRevenue,
          casteRevenue: casteRevenue,
          filteredPayments: filteredPayments.whereType<Payment>().toList(),
        ),
      );
    });


final genderDistributionProvider =
    Provider.family<AsyncValue<Map<String, int>>, String>((ref, agentId) {
      final analyticsStateAsync = ref.watch(analyticsProvider(agentId));

      return analyticsStateAsync.when(
        loading: () => const AsyncValue.loading(),
        error: (e, s) => AsyncValue.error(e, s),
        data: (analyticsState) {
          final Map<String, int> genderCount = {};
          for (final payment in analyticsState.filteredPayments) {
            final gender = payment.gender;
            genderCount[gender] = (genderCount[gender] ?? 0) + 1;
          }
          return AsyncValue.data(genderCount);
        },
      );
    });
final paymentStatusDistributionProvider =
    Provider.family<AsyncValue<Map<String, int>>, String>((ref, agentId) {
      final analyticsStateAsync = ref.watch(analyticsProvider(agentId));

      return analyticsStateAsync.when(
        loading: () => const AsyncValue.loading(),
        error: (e, s) => AsyncValue.error(e, s),
        data: (analyticsState) {
          final Map<String, int> statusCount = {
            'SUCCESS': analyticsState.successCount,
            'PENDING': analyticsState.pendingCount,
            'FAILED': analyticsState.failedCount,
          };
          return AsyncValue.data(statusCount);
        },
      );
    });
final regionDistributionProvider =
    Provider.family<AsyncValue<Map<String, int>>, String>((ref, agentId) {
      final analyticsStateAsync = ref.watch(analyticsProvider(agentId));

      return analyticsStateAsync.when(
        loading: () => const AsyncValue.loading(),
        error: (e, s) => AsyncValue.error(e, s),
        data: (analyticsState) {
          return AsyncValue.data(analyticsState.regionRevenue);
        },
      );
    });
final dailyRevenueDistributionProvider =
    Provider.family<AsyncValue<Map<DateTime, int>>, String>((ref, agentId) {
      final analyticsStateAsync = ref.watch(analyticsProvider(agentId));

      return analyticsStateAsync.when(
        loading: () => const AsyncValue.loading(),
        error: (e, s) => AsyncValue.error(e, s),
        data: (analyticsState) {
          return AsyncValue.data(analyticsState.dailyRevenue);
        },
      );
    });
final totalRevenueProvider = Provider.family<AsyncValue<int>, String>((
  ref,
  agentId,
) {
  final analyticsStateAsync = ref.watch(analyticsProvider(agentId));

  return analyticsStateAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
    data: (analyticsState) {
      return AsyncValue.data(analyticsState.totalRevenue);
    },
  );
});

final todayRevenueProvider = Provider.family<AsyncValue<int>, String>((
  ref,
  agentId,
) {
  final analyticsStateAsync = ref.watch(analyticsProvider(agentId));

  return analyticsStateAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
    data: (analyticsState) {
      return AsyncValue.data(analyticsState.todayRevenue);
    },
  );
});
final successCountProvider = Provider.family<AsyncValue<int>, String>((
  ref,
  agentId,
) {
  final analyticsStateAsync = ref.watch(analyticsProvider(agentId));

  return analyticsStateAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
    data: (analyticsState) {
      return AsyncValue.data(analyticsState.successCount);
    },
  );
});

final pendingCountProvider = Provider.family<AsyncValue<int>, String>((
  ref,
  agentId,
) {
  final analyticsStateAsync = ref.watch(analyticsProvider(agentId));

  return analyticsStateAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
    data: (analyticsState) {
      return AsyncValue.data(analyticsState.pendingCount);
    },
  );
});

final failedCountProvider = Provider.family<AsyncValue<int>, String>((
  ref,
  agentId,
) {
  final analyticsStateAsync = ref.watch(analyticsProvider(agentId));

  return analyticsStateAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
    data: (analyticsState) {
      return AsyncValue.data(analyticsState.failedCount);
    },
  );
});

final maleRevenueProvider = Provider.family<AsyncValue<int>, String>((
  ref,
  agentId,
) {
  final analyticsStateAsync = ref.watch(analyticsProvider(agentId));

  return analyticsStateAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
    data: (analyticsState) {
      return AsyncValue.data(analyticsState.maleRevenue);
    },
  );
});

final femaleRevenueProvider = Provider.family<AsyncValue<int>, String>((
  ref,
  agentId,
) {
  final analyticsStateAsync = ref.watch(analyticsProvider(agentId));

  return analyticsStateAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
    data: (analyticsState) {
      return AsyncValue.data(analyticsState.femaleRevenue);
    },
  );
});

final otherRevenueProvider = Provider.family<AsyncValue<int>, String>((
  ref,
  agentId,
) {
  final analyticsStateAsync = ref.watch(analyticsProvider(agentId));

  return analyticsStateAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
    data: (analyticsState) {
      return AsyncValue.data(analyticsState.otherRevenue);
    },
  );
});

