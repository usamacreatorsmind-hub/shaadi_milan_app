import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class RemoteConfigService {
  RemoteConfigService._();

  static final RemoteConfigService instance = RemoteConfigService._();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  static const String _keyLatestBuild = 'latest_build_number';

  int get latestBuildNumber => _remoteConfig.getInt(_keyLatestBuild);

  Future<void> init() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );

    await _remoteConfig.setDefaults({_keyLatestBuild: 1});

    await _remoteConfig.fetchAndActivate();
  }

  Future<void> checkForUpdate(BuildContext context) async {
    try {
      await init();

      final info = await PackageInfo.fromPlatform();

      final currentBuild = int.tryParse(info.buildNumber) ?? 0;

      final packageName = info.packageName;

      final remoteBuild = latestBuildNumber;

      debugPrint('Current Build: $currentBuild | Remote Build: $remoteBuild');

      final needsUpdate = currentBuild < remoteBuild;

      if (needsUpdate && context.mounted) {
        _showForceUpdateDialog(context, packageName);
      }
    } catch (e) {
      debugPrint('Remote config error: $e');
    }
  }

  void _showForceUpdateDialog(BuildContext context, String packageName) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => PopScope(
        canPop: true,
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
    final Uri uri = Uri.parse(
      'https://play.google.com/store/apps/details?id=$packageName',
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
