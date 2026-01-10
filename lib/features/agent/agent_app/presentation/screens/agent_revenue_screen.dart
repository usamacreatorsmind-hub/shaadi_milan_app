import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class AgentRevenueScreen extends ConsumerStatefulWidget {
  final String agentId;

  const AgentRevenueScreen({super.key, required this.agentId});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AgentRevenueScreenState();
}

class _AgentRevenueScreenState extends ConsumerState<AgentRevenueScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("This is revenue screen${widget.agentId}"));
  }
}
