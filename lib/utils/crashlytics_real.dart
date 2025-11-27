import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class Crashlytics {
  static FirebaseCrashlytics get _instance => FirebaseCrashlytics.instance;

  static void setupErrorHandlers() {
    FlutterError.onError = (details) {
      _instance.recordFlutterFatalError(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      _instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  static Future<void> enableCollection() async {
    await _instance.setCrashlyticsCollectionEnabled(true);
  }

  static Future<void> logError(
    dynamic error,
    StackTrace stack, {
    bool fatal = false,
  }) async {
    await _instance.recordError(error, stack, fatal: fatal);
  }
}

