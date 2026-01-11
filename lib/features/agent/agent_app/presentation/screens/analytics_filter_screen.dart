import 'package:arvika_marriage_bureau/core/filters/revenue_filter_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnalyticsFilterScreen extends ConsumerStatefulWidget {
  const AnalyticsFilterScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AnalyticsFilterScreenState();
}

class _AnalyticsFilterScreenState extends ConsumerState<AnalyticsFilterScreen> {
  // text controllers

  final TextEditingController stateCcontroller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  late final DateTime endDate;

  final TextEditingController religionController = TextEditingController();
  final TextEditingController casteController = TextEditingController();
  late final DateTime startDate;
  late final String gender;

  @override
  Widget build(BuildContext context) {


    
    final filterState = ref.watch(revenueFilterProvider);
     
    return Container();
  }
}
