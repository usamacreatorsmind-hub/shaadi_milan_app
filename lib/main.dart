import 'package:arvika_marriage_bureau/core/env/app_env.dart';
import 'package:arvika_marriage_bureau/core/env/app_env_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
// NOTE: generate firebase_options.dart via `flutterfire configure`
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppEnvConfig.init(environment: AppEnvironment.prod);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: App()));
}
