import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class RemoteConfigService {
  final _remoteConfig = FirebaseRemoteConfig.instance;

  // Single key set — same app, same build, covers both user & agent
  static const String _keyMinBuild = 'min_build_number';
  static const String _keyLatestBuild = 'latest_build_number';

  int get minBuildNumber => _remoteConfig.getInt(_keyMinBuild);
  int get latestBuildNumber => _remoteConfig.getInt(_keyLatestBuild);

  Future<void> init() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    await _remoteConfig.fetchAndActivate();
  }

  /// Called once on app start from App.initState — covers both user & agent.
  Future<void> checkForUpdate(BuildContext context) async {
    try {
      await init();

      final info = await PackageInfo.fromPlatform();
      final currentBuild = int.tryParse(info.buildNumber) ?? 0;
      final packageName = info.packageName;

      final needsUpdate =
          currentBuild < minBuildNumber || currentBuild < latestBuildNumber;

      if (needsUpdate && context.mounted) {
        _showForceUpdateDialog(context, packageName);
      }
    } catch (_) {
      // Silent fail — don't block app launch if Remote Config is unreachable
    }
  }

  void _showForceUpdateDialog(BuildContext context, String packageName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Update Required'),
          content: const Text(
            'A new version of the app is available. Please update to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () => _openStore(packageName),
              child: const Text('Update Now'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openStore(String packageName) async {
    final uri = Uri.parse(
      'https://play.google.com/store/apps/details?id=$packageName',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
