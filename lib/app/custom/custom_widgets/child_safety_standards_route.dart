import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:shadi_milan/core/constants/app_constants.dart';

@RoutePage()
class ChildSafetyStandardsScreen extends StatefulWidget {
  const ChildSafetyStandardsScreen({super.key});

  @override
  State<ChildSafetyStandardsScreen> createState() => _ChildSafetyStandardsScreenState();
}

class _ChildSafetyStandardsScreenState extends State<ChildSafetyStandardsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppConstants.openUrl(AppConstants.childSafetyStandardsUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Child Safety Standards"), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security_outlined, size: 80, color: theme.colorScheme.primary),
              const SizedBox(height: 20),
              Text(
                "Child Safety Standards Declaration",
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Opening official Child Safety Standards Declaration web page...",
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => AppConstants.openUrl(AppConstants.childSafetyStandardsUrl),
                icon: const Icon(Icons.open_in_browser),
                label: const Text("Open in Browser"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
