 
import 'dev_env.dart';
import 'prod_env.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_env.dart';

class AppEnvConfig {
  static late final AppEnv _instance;

  static AppEnv get instance => _instance;

  static void init({required AppEnvironment environment}) {
    switch (environment) {
      case AppEnvironment.dev:
        _instance = AppEnvDev();
        break;
      case AppEnvironment.prod:
        _instance = AppEnvProd();
        break;
    }
  }

  AppEnvConfig._();

  static bool get isProd => _instance.environment == AppEnvironment.prod;
  static bool get isDev =>
      _instance.environment ==
      AppEnvironment.dev; // Private constructor to prevent instantiation
}

final appEnvProvider = Provider<AppEnv>((ref) {
  return AppEnvConfig.instance;
});
