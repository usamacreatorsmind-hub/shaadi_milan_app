import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class AgentActivitiesScreen extends ConsumerStatefulWidget {
  final String agentId;

  const AgentActivitiesScreen({required this.agentId, super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _State();
}

class _State extends ConsumerState<AgentActivitiesScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(child: Text('Agent Activities Screen${widget.agentId}')),
    );
  }
}
