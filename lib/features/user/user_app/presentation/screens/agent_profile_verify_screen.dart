import 'package:arvika_marriage_bureau/app/custom/shimmer.dart';
import 'package:arvika_marriage_bureau/app/router/app_router.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/controllers/agent_profile_controller.dart';
import 'package:auto_route/annotations.dart';
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
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
               
                ],
              ),

              // color: Theme.of(context).primaryColor,
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
                        :
                          // adds shimmer effect if profile not loaded  or thre is no link
                          ShimmerProfileCard(
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
                              ref
                                  .read(
                                    agentProfileControllerProvider(
                                      agentId,
                                    ).notifier,
                                  )
                                  .approveAgent();
                            },
                            child: const Text('Verify Agent'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Decline Agent'),
                                    content: const Text(
                                      'Are you sure you want to decline this agent?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // navigate to splash onboarding screen
                                          context.router.push(
                                            OnboardingRoute(),
                                          );

                                          Navigator.pop(context);
                                        },
                                        child: const Text('Decline'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Text('Decline Agent'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
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
            width: 110, // fixed label width
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
