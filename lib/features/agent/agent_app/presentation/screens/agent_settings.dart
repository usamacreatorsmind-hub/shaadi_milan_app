import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadi_milan/app/router/app_router.dart';

import '../../../../l10n/app_localizations.dart';

@RoutePage()
class AgentSettingsScreen extends ConsumerStatefulWidget {
  const AgentSettingsScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AgentSettingsState();
}

class _AgentSettingsState extends ConsumerState<AgentSettingsScreen> {
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logout),
        content: Text(AppLocalizations.of(context)!.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              FirebaseAuth.instance.signOut();
            },
            child: Text(
              AppLocalizations.of(context)!.logout,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ── Account ──────────────────────────────────────────────────────
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.lock_outline, color: theme.primaryColor),
                  title: Text(AppLocalizations.of(context)!.changePassword),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => context.pushRoute(ChangePasswordRoute()),
                ),
              ],
            ),
          ),

          // ── App Info ─────────────────────────────────────────────────────
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
                  title: Text(AppLocalizations.of(context)!.aboutUs),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => context.pushRoute(const AboutUsRoute()),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.policy_outlined,
                    color: theme.primaryColor,
                  ),
                  title: Text(AppLocalizations.of(context)!.privacyPolicy),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => context.pushRoute(const PrivacyPolicyRoute()),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.description_outlined,
                    color: theme.primaryColor,
                  ),
                  title: Text(AppLocalizations.of(context)!.termsAndConditions),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () =>
                      context.pushRoute(const TermsAndConditionsRoute()),
                ),
              ],
            ),
          ),

          // ── Logout ───────────────────────────────────────────────────────
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(Icons.logout, color: theme.colorScheme.error),
              title: Text(
                AppLocalizations.of(context)!.logout,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () => _showLogoutDialog(context),
            ),
          ),
        ],
      ),
    );
  }
}
