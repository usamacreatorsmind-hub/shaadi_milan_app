enum AppEnvironment { dev, prod }

abstract class AppEnv {
  AppEnvironment get environment;
  String get firebaseProjectId;
}
