import 'package:arvika_marriage_bureau/features/auth/presentation/providers/auth_providers.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/data/repositories_impl/agent_repository_impl.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class AgentEntityScreen extends ConsumerStatefulWidget {
  const AgentEntityScreen({super.key, required this.uid});

  final String uid;

  @override
  ConsumerState<AgentEntityScreen> createState() => _AgenProfileScreenState();
}

class _AgenProfileScreenState extends ConsumerState<AgentEntityScreen> {
  fetchData() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // fetch data using widget.uid form firebase or any other source
    debugPrint('Fetching data for agent ID: ${widget.uid}');
    // Example: You might fetch agent details from a repository
    final agent = await ref
        .read(agentRepositoryProvider)
        .fetchAgent(widget.uid);
    debugPrint('Agent Data: ${agent.agentName}');
    debugPrint('Agent Email: ${agent.agentEmail}');
    debugPrint('Agent Mobile: ${agent.agentMobile}');
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 100),
          Text('Agent Profile Screen'),
          Text('Agent ID: ${widget.uid}'),
          ElevatedButton(
            onPressed: () {
              fetchData();
            },
            child: Text("Elevated Button"),
          ),

          ElevatedButton(
            onPressed: () {
              // logout
              ref.read(authRepositoryProvider).logout();
            },
            child: Text("Logout"),
          ),
        ],
      ),
    );
  }
}
