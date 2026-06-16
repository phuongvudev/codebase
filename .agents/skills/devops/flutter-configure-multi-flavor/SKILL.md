---
name: flutter-configure-multi-flavor
description: Configure multi-flavor support in Flutter using `flutter_flavorizr`. Use when you need separate build configurations (e.g., dev, staging, prod) with distinct bundle IDs, app names, and environment variables.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Wed, 12 Jun 2024 13:00:00 GMT
---
# Multi-Flavor Configuration with flutter_flavorizr

## Contents
- [Prerequisites](#prerequisites)
- [Flavor Configuration (flavorizr.yaml)](#flavor-configuration-flavorizryaml)
- [Generation & Setup](#generation--setup)
- [Environment Management](#environment-management)
- [Best Practices: Environment Configuration Classes](#best-practices-environment-configuration-classes)
- [Advanced: Loading Config from dart-define](#advanced-loading-config-from-dart-define)
- [Advanced: Dynamic Configuration (Remote Server)](#advanced-dynamic-configuration-remote-server)
- [Advanced: Runtime Environment Switching (QA Builds)](#advanced-runtime-environment-switching-qa-builds)
- [Running & Building](#running--building)
- [Best Practices](#best-practices)

## Prerequisites

Add `flutter_flavorizr` to your `dev_dependencies` in `pubspec.yaml`.

```yaml
dev_dependencies:
  flutter_flavorizr: ^2.2.3
```

## Flavor Configuration (flavorizr.yaml)

Create a `flavorizr.yaml` in the project root. This file defines your flavors and their platform-specific properties.

```yaml
flavors:
  dev:
    app:
      name: "App Dev"
    android:
      applicationId: "com.example.app.dev"
    ios:
      bundleId: "com.example.app.dev"
  prod:
    app:
      name: "App"
    android:
      applicationId: "com.example.app"
    ios:
      bundleId: "com.example.app"
```

## Generation & Setup

Run the following command to generate the native configurations and Flutter entry points:

```bash
dart run flutter_flavorizr
```

This command will:
1. Update Android `build.gradle` and create flavor-specific directories.
2. Update iOS schemes and `Info.plist`.
3. Generate `lib/main_dev.dart`, `lib/main_prod.dart`, and `lib/flavors.dart`.

## Environment Management

Use the generated `F` class in `lib/flavors.dart` to manage environment-specific variables.

```dart
// Example usage in your app
Text(F.title)

// Accessing the current flavor
if (F.appFlavor == Flavor.dev) {
  // Show debug banner or use dev API
}
```

### Dart Defines (Recommended)
For secrets and CI/CD, use `--dart-define` and retrieve them in `flavors.dart`.

```dart
// In lib/flavors.dart
static String get apiUrl => String.fromEnvironment('API_URL');
```

## Best Practices: Environment Configuration Classes

Instead of relying on the static `F` class throughout the app, use abstract environment classes and inject them using `get_it`. This improves testability and follows clean architecture.

### 1. Define the Configuration Interface
```dart
// lib/core/config/app_config.dart
abstract class AppConfig {
  String get baseUrl;
  String get flavorName;
}
```

### 2. Implement Flavor-Specific Configs
```dart
// lib/core/config/dev_config.dart
class DevConfig implements AppConfig {
  @override
  String get baseUrl => 'https://dev-api.example.com';
  @override
  String get flavorName => 'dev';
}
```

### 3. Initialize in Entry Points
Modify `lib/main_dev.dart` and `lib/main_prod.dart` to register the correct config.

```dart
// lib/main_dev.dart
import 'package:flutter/material.dart';
import 'core/config/dev_config.dart';
import 'core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies(DevConfig());
  runApp(const MyApp());
}
```

## Advanced: Loading Config from dart-define

Use `--dart-define-from-file` to load multiple variables from a JSON file. This is safer than passing individual CLI flags.

### 1. Create a config file (`config/prod.json`)
```json
{
  "BASE_URL": "https://api.example.com",
  "FLAVOR_NAME": "production"
}
```

### 2. Access in AppConfig implementation
```dart
class ProdConfig implements AppConfig {
  @override
  String get baseUrl => const String.fromEnvironment('BASE_URL');
  @override
  String get flavorName => const String.fromEnvironment('FLAVOR_NAME');
}
```

### 3. Run with the config file
```bash
flutter run --flavor prod --dart-define-from-file=config/prod.json
```

## Advanced: Dynamic Configuration (Remote Server)

For feature flags or dynamic settings, fetch configuration from a server at startup.

### 1. Define an Async Config Service
```dart
class RemoteConfigService {
  late Map<String, dynamic> _settings;

  Future<void> init() async {
    // Simulate API call
    _settings = await fetchSettingsFromServer();
  }

  String get apiEndpoint => _settings['api_endpoint'];
}
```

### 2. Register in get_it
Use `registerSingletonAsync` to ensure the config is loaded before other services depend on it. See the [GetIt Skill](file:///Volumes/Data/workstation/personal/projects/flutter/codebase/.agents/skills/flutter-use-get-it/SKILL.md) for details on async initialization.

## Advanced: Runtime Environment Switching (QA Builds)

For internal testing, you may want to switch environments without re-building. **Note: This should be disabled in production.**

### 1. Implement a Persisted Config
Use `SharedPreferences` to store the user's environment choice.

```dart
class SwitchableConfig implements AppConfig {
  static const _key = 'selected_env';
  
  static Future<AppConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    final env = prefs.getString(_key) ?? 'prod';
    return env == 'dev' ? DevConfig() : ProdConfig();
  }

  static Future<void> save(String env) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, env);
  }
}
```

### 2. Re-initialize the App
After switching, reset `get_it` and re-run the initialization.

```dart
void switchEnvironment(String env) async {
  await SwitchableConfig.save(env);
  
  // Reset GetIt and re-configure
  await getIt.reset();
  final newConfig = await SwitchableConfig.load();
  await configureDependencies(newConfig);
  
  // Restart the app (or navigate to a splash screen)
  runApp(const MyApp()); 
}
```

## Running & Building

Always specify the flavor and the corresponding target entry point.

### CLI
```bash
# Run
flutter run --flavor dev -t lib/main_dev.dart

# Build
flutter build apk --flavor prod -t lib/main_prod.dart
```

### VS Code (launch.json)
```json
{
  "name": "Run Dev",
  "request": "launch",
  "type": "dart",
  "program": "lib/main_dev.dart",
  "args": ["--flavor", "dev"]
}
```

## Best Practices

- **Distinct Icons**: Use `flutter_launcher_icons` or flavorizr's icon support to give each flavor a different icon.
- **Firebase**: Place `google-services.json` in `android/app/src/<flavor>/` and use `flutterfire configure` to generate flavor-specific options.
- **CI/CD**: Pass flavor-specific secrets via `--dart-define` in your build pipelines.
- **Keep it Clean**: Use `flavorizr.yaml` instead of putting the configuration inside `pubspec.yaml`.
- **Naming**: Follow semantic naming for flavors (e.g., `dev`, `staging`, `prod`).
