import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arvika_marriage_bureau/core/app_version_config/remote_config_service.dart';

@RoutePage()
class AgentHomeScreen extends ConsumerStatefulWidget {
  const AgentHomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AgentHomeScreenState();
}

class _AgentHomeScreenState extends ConsumerState<AgentHomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await RemoteConfigService.instance.checkForUpdate(context);
        await RemoteConfigService.instance.checkForMaintenanceMode(context);
      } catch (e) {
        debugPrint('RemoteConfig check failed on AgentHomeScreen: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: Center(child: Text('Agent Home Screen')));
  }
}
