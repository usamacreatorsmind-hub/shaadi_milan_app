import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../auth/domain/states/agent_state.dart';

class AgentBottomSheet extends StatelessWidget {
  final AgentEntity agent;

  const AgentBottomSheet({super.key, required this.agent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Header Section
            _AgentHeader(agent: agent),

            const SizedBox(height: 24),

            // 🔹 Info Section
            _SectionCard(
              title: 'Agent Information',
              children: [
                _InfoRow(Icons.phone, 'Mobile', agent.agentMobile),
                _InfoRow(Icons.email_outlined, 'Email', agent.agentEmail),
                _InfoRow(
                  Icons.calendar_today_outlined,
                  'Registered On',
                  _formatDate(agent.registrationDate),
                ),
                _InfoRow(
                  Icons.location_on_outlined,
                  'Address',
                  agent.agentAddress,
                ),
              ],
            ),

            const SizedBox(height: 28),

            // 🔹 Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.call),
                    label: const Text('Call'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _call(agent.agentMobile),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('Email'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _email(agent.agentEmail),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────── Helpers ─────────────────

  static Widget _AgentHeader({required AgentEntity agent}) {
    return Row(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: Colors.redAccent.withOpacity(0.12),
          backgroundImage: NetworkImage(agent.primaryImageUrl),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                agent.agentName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  agent.role.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _SectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.grey.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  static Widget _InfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 12),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.year}';

  static void _call(String number) {
    launchUrl(Uri.parse('tel:$number'), mode: LaunchMode.externalApplication);
  }

  static void _email(String email) {
    launchUrl(Uri.parse('mailto:$email'), mode: LaunchMode.externalApplication);
  }
}
