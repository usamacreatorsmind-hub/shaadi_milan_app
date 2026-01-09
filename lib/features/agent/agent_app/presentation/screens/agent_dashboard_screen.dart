import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class AgentDashboardScreen extends ConsumerWidget {
  final String uid;

  const AgentDashboardScreen({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(child: Text('Agent Dashboard for Agent ID: $uid')),
    );
  }
}
