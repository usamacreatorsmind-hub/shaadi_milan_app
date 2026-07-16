import 'package:shadi_milan/core/constants/app_constants.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';
import 'package:url_launcher/url_launcher.dart';

class RemoteConfigService {
  RemoteConfigService._();

  static final RemoteConfigService instance = RemoteConfigService._();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  static const String _keyLatestBuild = 'latest_build_number';
  static const String _keyMaintenaceMode = 'isMaintenanceMode';

  int get latestBuildNumber => _remoteConfig.getInt(_keyLatestBuild);

  bool get isMaintenanceMode => _remoteConfig.getBool(_keyMaintenaceMode);

  Future<void> init() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );

    await _remoteConfig.setDefaults({
      _keyLatestBuild: 1,
      _keyMaintenaceMode: false,
    });

    await _remoteConfig.fetchAndActivate();
  }

  // check for maintenance mode and force update
  Future<void> checkForMaintenanceMode(BuildContext context) async {
    try {
      await init();

      if (isMaintenanceMode && context.mounted) {
        _showMaintenanceDialog(context);
      }
    } catch (e) {
      debugPrint('Remote config error: $e');
    }
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
          title: Text(AppLabels.updateRequiredTitle(context)),
          content: Text(AppLabels.updateRequiredMessage(context)),
          actions: [
            TextButton(
              onPressed: () => _openStore(packageName),
              child: Text(AppLabels.updateNowButton(context)),
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

  void _showMaintenanceDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Icon
                Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.construction_rounded,
                    size: 50,
                    color: Colors.orange,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  AppLabels.maintenanceModeTitle(context),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AppLabels.maintenanceModeSubtitle(context),
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  AppLabels.maintenanceModeMessage(context),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          AppLabels.maintenanceRestoringMessage(context),
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),

                const SizedBox(height: 12),

                Text(
                  AppLabels.pleaseWait(context),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
