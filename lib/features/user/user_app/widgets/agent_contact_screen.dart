import '../../../auth/domain/states/agent_state.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../presentation/controllers/agent_profile_controller.dart';

@RoutePage()
class AgentContactScreen extends ConsumerWidget {
  final String agentId;

  const AgentContactScreen({super.key, required this.agentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentAsync = ref.watch(AgentEntityControllerProvider(agentId));

    return Scaffold(
      appBar: AppBar(title: const Text('Agent Details'), centerTitle: true),
      body: agentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (agent) => _buildAgentDetails(context, agent),
      ),
    );
  }

  Widget _buildAgentDetails(BuildContext context, AgentEntity agent) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 80,
            backgroundImage:
                agent.photoUrl != null && agent.photoUrl!.isNotEmpty
                ? NetworkImage(agent.photoUrl!)
                : null,
            child: agent.photoUrl == null || agent.photoUrl!.isEmpty
                ? Icon(Icons.person, size: 80, color: Colors.grey[400])
                : null,
          ),
          const SizedBox(height: 20),
          Text(
            agent.agentName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // Text(
          //   'Agent ID: ${agent.agentId}',
          //   style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          // ),
          const SizedBox(height: 20),
          _buildContactTile(
            context,
            Icons.phone,
            'Call Agent',
            agent.agentMobile,
            () => _makePhoneCall(agent.agentMobile),
          ),
          _buildContactTile(
            context,
            Icons.email,
            'Email Agent',
            agent.agentEmail,
            () => _sendEmail(agent.agentEmail),
          ),
          _buildContactTile(
            context,
            Icons.calendar_today,
            'Registration Date',
            DateFormat('dd MMM yyyy').format(agent.registrationDate),
            null,
          ),
          _buildContactTile(context, Icons.work, 'Role', agent.role, null),
        ],
      ),
    );
  }

  Widget _buildContactTile(
    BuildContext context,
    IconData icon,
    String title,
    String? subtitle,
    VoidCallback? onTap,
  ) {
    if (subtitle == null || subtitle.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: onTap != null
            ? const Icon(Icons.arrow_forward_ios, size: 18)
            : null,
        onTap: onTap,
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $email';
    }
  }
}
