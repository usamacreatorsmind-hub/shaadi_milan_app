import 'package:auto_route/auto_route.dart';
import 'package:shadi_milan/core/constants/app_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadi_milan/app/router/app_router.dart';
import '../../../../../core/constants/app_labels.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/app_translation_service.dart';

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
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                context.router.replaceAll([const RoleSelectionRoute()]);
              }
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
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.language, color: theme.primaryColor),
                  title: Text(AppLabels.language(context)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showLanguageDialog(context, ref),
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
                  onTap: () => AppConstants.openUrl(AppConstants.privacyPolicyUrl),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.description_outlined,
                    color: theme.primaryColor,
                  ),
                  title: Text(AppLocalizations.of(context)!.termsAndConditions),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => AppConstants.openUrl(AppConstants.termsAndConditionsUrl),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.security_outlined,
                    color: theme.primaryColor,
                  ),
                  title: const Text("Child Safety Standards"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => AppConstants.openUrl(AppConstants.childSafetyStandardsUrl),
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

void _showLanguageDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(AppLabels.selectLanguage(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppTranslation.supportedTranslations.map((translation) {
            return ListTile(
              title: Text(translation.nativeName),
              subtitle: Text(translation.name),
              onTap: () {
                ref
                    .read(appTranslationServiceProvider)
                    .setLanguageCode(translation.languageCode);
                ref.read(localeProvider.notifier).state =
                    Locale(translation.languageCode);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      );
    },
  );
}
