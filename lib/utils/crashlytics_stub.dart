class CrashlyticsBridge {
  const CrashlyticsBridge();

  Future<void> setCollectionEnabled(bool enabled) async {}
  Future<void> recordFlutterFatalError(Object errorDetails) async {}
  Future<void> recordError(dynamic exception, StackTrace stack,
      {bool fatal = false}) async {}
}

class Crashlytics {
  static const CrashlyticsBridge instance = CrashlyticsBridge();

  static void setupErrorHandlers() {}

  static Future<void> enableCollection() async {}

  static Future<void> logError(dynamic error, StackTrace stack,
          {bool fatal = false}) async =>
      instance.recordError(error, stack, fatal: fatal);
}

