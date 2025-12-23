import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/agent_profile_controller.dart';

@RoutePage()
class AgentDashboardScreen extends ConsumerWidget {
  final String uid;
  const AgentDashboardScreen({required this.uid, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { 
    return Scaffold();
  }
}
