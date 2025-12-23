import 'app_env.dart';

class AppEnvDev implements AppEnv {
  @override
  AppEnvironment get environment => AppEnvironment.dev;

  @override
  String get firebaseProjectId => 'arvika-marriage-dev';
}
