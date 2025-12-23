import 'app_env.dart';

class AppEnvProd implements AppEnv {
  @override
  AppEnvironment get environment => AppEnvironment.prod;

  @override
  String get firebaseProjectId => 'arvika-marriage-prod';
}
