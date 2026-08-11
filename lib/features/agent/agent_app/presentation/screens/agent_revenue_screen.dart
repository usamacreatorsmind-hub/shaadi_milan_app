import 'package:auto_route/auto_route.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../app/custom/custom_widgets/drawer.dart';
import '../../../../../app/custom/custom_widgets/revenue_dashboard_tabbar.dart';
import '../../../../../core/filters/revenue_filter_controller.dart';
import '../../../../../core/filters/revenue_filter_right_sheet.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../user/user_razorpay/domain/states/payment.dart';
import '../../domain/states/analytics_state.dart';
import '../notifier/analytics_provider.dart';
import '../notifier/user_nofier.dart';
import 'agen_profile.screen.dart';

@RoutePage()
class AgentRevenueScreen extends ConsumerStatefulWidget {
  final String agentId;
  const AgentRevenueScreen({super.key, required this.agentId});

  @override
  ConsumerState<AgentRevenueScreen> createState() => _AgentRevenueScreenState();
}

class _AgentRevenueScreenState extends ConsumerState<AgentRevenueScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(usersPaymentsNotifierProvider.notifier).getUsersPayment(agentId: widget.agentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(analyticsProvider(widget.agentId));

    final theme = Theme.of(context);

    return Scaffold(
      drawer: AppDrawer(agentAsync: ref.watch(agentProvider(widget.agentId))),

      body: analyticsAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: theme.primaryColor)),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (analytics) {
          return DefaultTabController(
            length: 4,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    title: Text(AppLocalizations.of(context)!.revenueDashboard),
                    backgroundColor: theme.primaryColor,
                    foregroundColor: theme.colorScheme.onPrimary,
                    pinned: true,
                    floating: true,
                    forceElevated: innerBoxIsScrolled,
                    actions: [
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.filter_list),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) => const RevenueFilterRightSheet(),
                              );
                            },
                          ),
                          if (ref.read(revenueFilterProvider.notifier).state.city.isNotEmpty ||
                              ref.read(revenueFilterProvider.notifier).state.religion.isNotEmpty ||
                              ref.read(revenueFilterProvider.notifier).state.caste.isNotEmpty ||
                              ref.read(revenueFilterProvider.notifier).state.gender.isNotEmpty ||
                              ref.read(revenueFilterProvider.notifier).state.startDate.day != DateTime.now().day ||
                              ref.read(revenueFilterProvider.notifier).state.endDate.day != DateTime.now().day)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              ),
                            ),
                        ],
                      ),
                    ],
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(52), // FIXED HEIGHT
                      child: RevenueDashboardTabbar(),
                    ),
                  ),
                ];
              },
              body: Builder(
                builder: (context) => TabBarView(
                  children: [
                    // Overview Tab
                    CustomScrollView(
                      key: const PageStorageKey<String>('overview'),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              _RevenueRow(analytics),
                              const SizedBox(height: 24),
                              _PaymentStatusPie(analytics),

                              FlutterCarousel(
                                options: FlutterCarouselOptions(
                                  height: 550,
                                  scrollBehavior: const ScrollBehavior(),

                                  allowImplicitScrolling: true,
                                  autoPlay: true,
                                ),
                                items: [
                                  Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!.revenueByGender,
                                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 16),
                                          SizedBox(
                                            height: 300,

                                            child: PieChart(
                                              PieChartData(
                                                sectionsSpace: 2,
                                                centerSpaceRadius: 40,
                                                sections: [
                                                  PieChartSectionData(
                                                    value: analytics.maleRevenue.toDouble(),
                                                    title: '${AppLocalizations.of(context)!.male}\n₹${analytics.maleRevenue}',
                                                    color: Colors.blue,
                                                    radius: 50,
                                                    titleStyle: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  PieChartSectionData(
                                                    value: analytics.femaleRevenue.toDouble(),
                                                    title: '${AppLocalizations.of(context)!.female}\n₹${analytics.femaleRevenue}',
                                                    color: Colors.pink,
                                                    radius: 50,
                                                    titleStyle: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  PieChartSectionData(
                                                    value: analytics.otherRevenue.toDouble(),
                                                    title: '${AppLocalizations.of(context)!.other}\n₹${analytics.otherRevenue}',
                                                    color: Colors.purple,
                                                    radius: 50,
                                                    titleStyle: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              _LegendItem(color: Colors.blue, text: AppLocalizations.of(context)!.male),
                                              const SizedBox(width: 16),
                                              _LegendItem(color: Colors.pink, text: AppLocalizations.of(context)!.female),
                                              const SizedBox(width: 16),
                                              _LegendItem(color: Colors.purple, text: AppLocalizations.of(context)!.other),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!.revenueByReligion,
                                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 16),
                                          SizedBox(
                                            height: 300,
                                            child: PieChart(
                                              PieChartData(
                                                sectionsSpace: 2,
                                                centerSpaceRadius: 40,
                                                sections: analytics.religionRevenue.entries.map((entry) {
                                                  return PieChartSectionData(
                                                    value: entry.value.toDouble(),
                                                    title: '${entry.key}\n₹${entry.value}',
                                                    color: Colors.primaries[entry.key.hashCode % Colors.primaries.length],
                                                    radius: 50,
                                                    titleStyle: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            alignment: WrapAlignment.center,
                                            children: analytics.religionRevenue.entries.map((entry) {
                                              return _LegendItem(
                                                color: Colors.primaries[entry.key.hashCode % Colors.primaries.length],
                                                text: entry.key,
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!.revenueByCaste,

                                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 16),
                                          SizedBox(
                                            height: 300,
                                            child: PieChart(
                                              PieChartData(
                                                sectionsSpace: 2,
                                                centerSpaceRadius: 40,
                                                sections: analytics.casteRevenue.entries.map((entry) {
                                                  return PieChartSectionData(
                                                    value: entry.value.toDouble(),
                                                    title: '${entry.key}\n₹${entry.value}',
                                                    color: Colors.accents[entry.key.hashCode % Colors.accents.length],
                                                    radius: 50,
                                                    titleStyle: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            alignment: WrapAlignment.center,
                                            children: analytics.casteRevenue.entries.map((entry) {
                                              return _LegendItem(
                                                color: Colors.accents[entry.key.hashCode % Colors.accents.length],
                                                text: entry.key,
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                    // Trends Tab
                    CustomScrollView(
                      key: const PageStorageKey<String>('trends'),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverList(delegate: SliverChildListDelegate([_DailyRevenueChart(analytics)])),
                        ),
                      ],
                    ),
                    // Regions Tab
                    CustomScrollView(
                      key: const PageStorageKey<String>('regions'),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              // bar chart widget
                              _RegionRevenueBarChart(analytics.regionRevenue),
                              const SizedBox(height: 24),

                              _RegionRevenueList(analytics.regionRevenue),
                            ]),
                          ),
                        ),
                      ],
                    ),
                    // Transactions Tab
                    _TransactionList(payments: analytics.filteredPayments),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RegionRevenueBarChart extends StatelessWidget {
  final Map<String, int> regionRevenue;

  const _RegionRevenueBarChart(this.regionRevenue);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (regionRevenue.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(child: Text(AppLocalizations.of(context)!.noRegionDataForChart)),
        ),
      );
    }

    final sortedEntries = regionRevenue.entries.toList()..sort((a, b) => b.value.compareTo(a.value)); // Sort by revenue descending

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.regionRevenueDistribution,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  barGroups: sortedEntries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data.value.toDouble(),
                          color: Colors.teal, // Consistent color for regions
                          width: 16,
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                        ),
                      ],
                      showingTooltipIndicators: [0],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < sortedEntries.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(sortedEntries[value.toInt()].key, style: const TextStyle(fontSize: 10)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    enabled: true,
                    allowTouchBarBackDraw: true,

                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final region = sortedEntries[group.x.toInt()].key;
                        return BarTooltipItem(
                          '$region\n',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          children: <TextSpan>[
                            TextSpan(
                              text: rod.toY.toInt().toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  final List<Payment> payments;

  const _TransactionList({required this.payments});

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noTransactionsFound));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(payment.status).withOpacity(0.1),
              child: Icon(_getStatusIcon(payment.status), color: _getStatusColor(payment.status)),
            ),
            title: Text(payment.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${payment.region ?? AppLocalizations.of(context)!.notAvailableShort}, ${payment.district ?? AppLocalizations.of(context)!.notAvailableShort}",
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(payment.createdAt),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("₹${payment.amount}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (payment.agentCommission > 0)
                  Text(
                    "${AppLocalizations.of(context)!.commission}: ₹${payment.agentCommission.toStringAsFixed(2)}",
                    style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                Text(
                  payment.status,
                  style: TextStyle(color: _getStatusColor(payment.status), fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SUCCESS':
      case 'PAID':
      case 'CAPTURED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'FAILED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'SUCCESS':
      case 'PAID':
      case 'CAPTURED':
        return Icons.check;
      case 'PENDING':
        return Icons.access_time;
      case 'FAILED':
        return Icons.close;
      default:
        return Icons.info_outline;
    }
  }
}

class _RevenueRow extends StatelessWidget {
  final AnalyticsState analytics;

  const _RevenueRow(this.analytics);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _RevenueCard(AppLocalizations.of(context)!.totalRevenue, '₹${analytics.totalRevenue}'),
            const SizedBox(width: 12),
            _RevenueCard(AppLocalizations.of(context)!.todayRevenue, '₹${analytics.todayRevenue}'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _RevenueCard(
              AppLocalizations.of(context)!.yourCommission,
              '₹${analytics.totalCommission.toStringAsFixed(2)}',
              color: Colors.orange,
            ),
          ],
        ),
      ],
    );
  }
}

class _RevenueCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? color;

  const _RevenueCard(this.title, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(title, style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
              const SizedBox(height: 8),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color ?? theme.primaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentStatusPie extends StatelessWidget {
  final AnalyticsState analytics;

  const _PaymentStatusPie(this.analytics);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(AppLocalizations.of(context)!.paymentStatus, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      value: analytics.successCount.toDouble(),
                      title: '${analytics.successCount}',
                      color: Colors.green,
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      value: analytics.pendingCount.toDouble(),
                      title: '${analytics.pendingCount}',
                      color: Colors.orange,
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      value: analytics.failedCount.toDouble(),
                      title: '${analytics.failedCount}',
                      color: Colors.red,
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(color: Colors.green, text: AppLocalizations.of(context)!.success),
                const SizedBox(width: 16),
                _LegendItem(color: Colors.orange, text: AppLocalizations.of(context)!.pending),
                const SizedBox(width: 16),
                _LegendItem(color: Colors.red, text: AppLocalizations.of(context)!.failed),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _DailyRevenueChart extends StatelessWidget {
  final AnalyticsState analytics;

  const _DailyRevenueChart(this.analytics);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortedEntries = analytics.dailyRevenue.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.dailyRevenueTrend,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 350,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < sortedEntries.length) {
                            final date = sortedEntries[value.toInt()].key;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text("${date.day}/${date.month}", style: const TextStyle(fontSize: 10)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(sortedEntries.length, (i) => FlSpot(i.toDouble(), sortedEntries[i].value.toDouble())),
                      isCurved: true,
                      color: theme.primaryColor,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: true, color: theme.primaryColor.withOpacity(0.1)),
                    ),
                  ],
                ),
              ),
            ),

            // add another chart
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.revenueByPaymentStatus,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 350,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [BarChartRodData(toY: analytics.successCount.toDouble(), color: Colors.green, width: 20)],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [BarChartRodData(toY: analytics.pendingCount.toDouble(), color: Colors.orange, width: 20)],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [BarChartRodData(toY: analytics.failedCount.toDouble(), color: Colors.red, width: 20)],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return Text(AppLocalizations.of(context)!.success);
                            case 1:
                              return Text(AppLocalizations.of(context)!.pending);
                            case 2:
                              return Text(AppLocalizations.of(context)!.failed);
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String status;
                        switch (group.x.toInt()) {
                          case 0:
                            status = AppLocalizations.of(context)!.success;
                            break;
                          case 1:
                            status = AppLocalizations.of(context)!.pending;
                            break;
                          case 2:
                            status = AppLocalizations.of(context)!.failed;
                            break;
                          default:
                            status = '';
                        }
                        return BarTooltipItem(
                          '$status\n',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          children: <TextSpan>[
                            TextSpan(
                              text: rod.toY.toInt().toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.revenueByReligion,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 350,
              child: BarChart(
                BarChartData(
                  barGroups: analytics.religionRevenue.entries.map((entry) {
                    final index = analytics.religionRevenue.keys.toList().indexOf(entry.key);
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: Colors.purple, // You can customize colors
                          width: 20,
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final religion = analytics.religionRevenue.keys.elementAt(value.toInt());
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(religion, style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final religion = analytics.religionRevenue.keys.elementAt(group.x.toInt());
                        return BarTooltipItem(
                          '$religion\n',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          children: <TextSpan>[
                            TextSpan(
                              text: rod.toY.toInt().toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(AppLocalizations.of(context)!.revenueByCaste, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 350,
              child: BarChart(
                BarChartData(
                  barGroups: analytics.casteRevenue.entries.map((entry) {
                    final index = analytics.casteRevenue.keys.toList().indexOf(entry.key);
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: Colors.deepOrange, // You can customize colors
                          width: 20,
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final caste = analytics.casteRevenue.keys.elementAt(value.toInt());
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(caste, style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final caste = analytics.casteRevenue.keys.elementAt(group.x.toInt());
                        return BarTooltipItem(
                          '$caste\n',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          children: <TextSpan>[
                            TextSpan(
                              text: rod.toY.toInt().toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegionRevenueList extends StatelessWidget {
  final Map<String, int> regionRevenue;

  const _RegionRevenueList(this.regionRevenue);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(AppLocalizations.of(context)!.regions, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ),
            const Divider(),
            if (regionRevenue.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: Text(AppLocalizations.of(context)!.noRegionData)),
              )
            else
              ...regionRevenue.entries.map((e) {
                return ListTile(
                  title: Text(e.key),
                  trailing: Text(
                    '₹ ${e.value}',
                    style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
