import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadi_milan/core/constants/app_constants.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';

class RevenueDashboardTabbar extends ConsumerStatefulWidget {
  const RevenueDashboardTabbar({super.key});

  @override
  ConsumerState<RevenueDashboardTabbar> createState() =>
      _RevenueDashboardTabbarState();
}

class _RevenueDashboardTabbarState
    extends ConsumerState<RevenueDashboardTabbar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TabBar(
      isScrollable: true,
      indicatorSize: TabBarIndicatorSize.tab,
      physics: const BouncingScrollPhysics(),
      indicator: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      ),
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.normal,
      ),
      labelColor: theme.colorScheme.onSecondary,
      unselectedLabelColor: theme.colorScheme.onPrimary.withOpacity(0.7),
      tabs: [
        TabbarItem(label: AppLabels.overview(context)),
        TabbarItem(label: AppLabels.trends(context)),
        TabbarItem(label: AppLabels.regions(context)),
        TabbarItem(label: AppLabels.transactions(context)),
      ],
    );
  }
}

class TabbarItem extends StatelessWidget {
  final String label;

  const TabbarItem({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 48,
      child: Center(child: Text(label, textAlign: TextAlign.center)),
    );
  }
}
