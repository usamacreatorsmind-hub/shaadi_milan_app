import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class AgentnotificationScreen extends ConsumerStatefulWidget {
  const AgentnotificationScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AgentnotificationScreenState();
}

class _AgentnotificationScreenState
    extends ConsumerState<AgentnotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const Center(child: Text('No new notifications')),
    );
  }
}
