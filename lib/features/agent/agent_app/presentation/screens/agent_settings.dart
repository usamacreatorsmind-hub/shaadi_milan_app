import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class AgentSettingsScreen extends ConsumerStatefulWidget {
  const AgentSettingsScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AgentSettingsState();
}

class _AgentSettingsState extends ConsumerState<AgentSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.person_outline,
                    color: theme.primaryColor,
                  ),
                  title: const Text('Edit Profile'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // TODO: Navigate to edit profile screen
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.lock_outline, color: theme.primaryColor),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // TODO: Navigate to change password screen
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.notifications_none,
                    color: theme.primaryColor,
                  ),
                  title: const Text('Notification Settings'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // TODO: Navigate to notification settings screen
                  },
                ),
              ],
            ),
          ),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline, color: theme.primaryColor),
                  title: const Text('About Us'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // TODO: Navigate to about us screen
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.policy_outlined,
                    color: theme.primaryColor,
                  ),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // TODO: Navigate to privacy policy screen
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.description_outlined,
                    color: theme.primaryColor,
                  ),
                  title: const Text('Terms and Conditions'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // TODO: Navigate to terms and conditions screen
                  },
                ),
              ],
            ),
          ),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(Icons.logout, color: theme.colorScheme.error),
              title: Text(
                'Logout',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () {
                // TODO: Implement logout functionality
              },
            ),
          ),
        ],
      ),
    );
  }
}
