---
name: flutter-setup-crash-monitoring
description: Implement professional crash monitoring and error reporting for Flutter using a provider-agnostic approach (Firebase Crashlytics, Sentry, etc.).
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Mon, 16 Jun 2024 12:00:00 GMT
---
# Crash Monitoring & Error Reporting

## Contents
- [Prerequisites](#prerequisites)
- [Abstraction Layer (Clean Architecture)](#abstraction-layer-clean-architecture)
- [Global Error Catching (2025 Standard)](#global-error-catching-2025-standard)
- [Provider Setup: Firebase Crashlytics](#provider-setup-firebase-crashlytics)
- [Provider Setup: Sentry](#provider-setup-sentry)
- [Automated Symbol Upload (CI/CD)](#automated-symbol-upload-cicd)
- [Best Practices](#best-practices)

## Prerequisites

- **Firebase Project:** If using Crashlytics.
- **Sentry Project:** If using Sentry.
- **Fastlane:** Recommended for symbol upload automation (see [Fastlane Skill](../devops/flutter-setup-fastlane-ci-cd/SKILL.md)).

## Abstraction Layer (Clean Architecture)

Always use an interface to avoid direct dependency on a specific SDK throughout the app.

```dart
// lib/domain/monitoring/crash_reporter.dart
abstract class CrashReporter {
  Future<void> initialize();
  Future<void> recordError(dynamic error, StackTrace stack, {dynamic reason, bool fatal = false});
  Future<void> log(String message);
  Future<void> setUserIdentifier(String identifier);
}
```

## Global Error Catching (2025 Standard)

Hook into both synchronous Flutter errors and asynchronous platform errors.

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final reporter = getIt<CrashReporter>();
  await reporter.initialize();

  // 1. Capture Flutter framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    reporter.recordError(details.exception, details.stack, fatal: true);
  };

  // 2. Capture asynchronous errors not caught by Flutter
  PlatformDispatcher.instance.onError = (error, stack) {
    reporter.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp());
}
```

## Provider Setup: Firebase Crashlytics

### Installation
```bash
flutter pub add firebase_crashlytics firebase_core
```

### Implementation
```dart
class FirebaseCrashReporter implements CrashReporter {
  @override
  Future<void> initialize() async {
    await Firebase.initializeApp();
    // Enable collection in production only
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
  }

  @override
  Future<void> recordError(error, stack, {reason, fatal = false}) {
    return FirebaseCrashlytics.instance.recordError(error, stack, reason: reason, fatal: fatal);
  }
}
```

## Provider Setup: Sentry

### Installation
```bash
flutter pub add sentry_flutter
```

### Implementation
```dart
class SentryCrashReporter implements CrashReporter {
  @override
  Future<void> initialize() async {
    await SentryFlutter.init((options) {
      options.dsn = 'YOUR_DSN';
      options.tracesSampleRate = 1.0;
    });
  }

  @override
  Future<void> recordError(error, stack, {reason, fatal = false}) {
    return Sentry.captureException(error, stackTrace: stack);
  }
}
```

## Automated Symbol Upload (CI/CD)

### iOS (dSYMs)
In your `Fastfile`:
```ruby
lane :upload_symbols do
  upload_symbols_to_crashlytics(dsym_path: "./build/ios/archive/Runner.xcarchive/dSYMs")
end
```

### Android (Mapping Files)
In `android/app/build.gradle`:
```gradle
android {
    buildTypes {
        release {
            firebaseCrashlytics {
                nativeSymbolUploadEnabled true
                unstrippedNativeLibsDir 'build/intermediates/merged_native_libs/release/out/lib'
            }
        }
    }
}
```

## Best Practices

- **Privacy:** Never log PII (Personally Identifiable Information) in breadcrumbs or logs.
- **Breadcrumbs:** Log significant UI navigation or state transitions to help reproduce crashes.
- **Hybrid Setup:** Use Sentry for performance profiling and Crashlytics for raw crash data and BigQuery export.
- **Offline:** Both SDKs cache reports locally and upload them when the connection is restored.
