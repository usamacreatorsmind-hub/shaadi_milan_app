import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadi_milan/features/user/user_app/data/repositories_impl/agent_repository_impl.dart';

import '../../../../core/constants/app_labels.dart';

@RoutePage()
class ViewAgentProfileScreen extends ConsumerWidget {
  final String agentId;

  const ViewAgentProfileScreen({super.key, required this.agentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentAsync = ref.watch(agentByIdProvider(agentId));

    return Scaffold(
      appBar: AppBar(title: Text(AppLabels.agentDetails(context))),
      body: agentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('${AppLabels.errorOccurred(context)}: $error')),
        data: (agent) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: agent.profileImageUrl.isNotEmpty
                        ? NetworkImage(agent.profileImageUrl)
                        : null,
                    child: agent.profileImageUrl.isEmpty
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                Text(agent.agentName),
                _info(AppLabels.staffId(context), agent.agentId),
                _info(AppLabels.email(context), agent.agentEmail),
                _info(AppLabels.phone(context), agent.agentMobile),
                _info(AppLabels.address(context), agent.agentAddress),
                _info(AppLabels.city(context), agent.agentCity),
                _info(AppLabels.state(context), agent.agentState),

                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text('$label: $value'),
    );
  }
}
