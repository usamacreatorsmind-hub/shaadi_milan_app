import '../../../../../app/custom/shimmer.dart';
import '../../../user_app/presentation/controllers/agent_profile_controller.dart';
 
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class AgentProfileVerifyScreen extends ConsumerWidget {
  final String agentId;

  const AgentProfileVerifyScreen({super.key, required this.agentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentAsync = ref.watch(agentProfileControllerProvider(agentId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: agentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (agent) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    width: double.infinity,
                    child: agent.photoUrl != null && agent.photoUrl!.isNotEmpty
                        ? Image.network(
                            agent.photoUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.grey,
                            ),
                          )
                        : ShimmerProfileCard(
                            height: MediaQuery.of(context).size.height * 0.4,
                            width: double.infinity,
                          ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      agent.agentName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _info('Agent ID', agent.agentId),
                  _info('Name', agent.agentName),
                  _info('Mobile', agent.agentMobile),
                  _info('Email', agent.email),
                  _info(
                    'Registration Date',
                    '${agent.registrationDate.day}/${agent.registrationDate.month}/${agent.registrationDate.year}',
                  ),
                  _info('Role', agent.role),
                  const Divider(height: 30),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            onPressed: () {
                              context.router.pop(true);
                            },
                            child: const Text('Yes, I agree'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              context.router.pop();
                            },
                            child: const Text("No, I don't agree"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
