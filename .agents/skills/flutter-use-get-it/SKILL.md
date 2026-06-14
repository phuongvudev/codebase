---
name: flutter-use-get-it
description: Use `get_it` as a service locator for dependency injection in Flutter. Use to decouple classes, manage service lifecycles, and improve testability.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Wed, 12 Jun 2024 15:00:00 GMT
---
# Dependency Injection with GetIt

## Contents
- [Prerequisites](#prerequisites)
- [Registration Types](#registration-types)
- [Centralized Initialization](#centralized-initialization)
- [Best Practices: Constructor Injection](#best-practices-constructor-injection)
- [Handling Async Initialization](#handling-async-initialization)
- [Workflow](#workflow)
- [Example](#example)

## Prerequisites

Add `get_it` to your `dependencies` in `pubspec.yaml`.

```yaml
dependencies:
  get_it: ^7.7.0
```

## Registration Types

| Method | Lifecycle | Best For... |
| :--- | :--- | :--- |
| **`registerSingleton<T>(T instance)`** | Created at registration | Config, Storage, Logging. |
| **`registerLazySingleton<T>(T FactoryFunc)`** | Created on first access | API Clients, Databases, Repositories. |
| **`registerFactory<T>(T FactoryFunc)`** | New instance every call | ViewModels, BLoCs, transient state. |

## Centralized Initialization

Create a dedicated file (e.g., `lib/core/di/injection.dart`) to manage all registrations. In multi-flavor apps, pass the environment configuration to this function.

```dart
import 'package:get_it/get_it.dart';
import '../config/app_config.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies(AppConfig config) async {
  // 1. Environment Configuration
  getIt.registerSingleton<AppConfig>(config);

  // 2. External Services (Async)
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // 3. Remote Configuration (Async Singleton)
  getIt.registerSingletonAsync<RemoteConfigService>(() async {
    final service = RemoteConfigService();
    await service.init(); // Fetches data from server
    return service;
  });

  // 4. Data Sources / API Clients
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(
    Dio(BaseOptions(baseUrl: getIt<AppConfig>().baseUrl)),
  ));
}
```

## Best Practices: Constructor Injection

**Never** call `getIt<T>()` inside your business logic classes. Always pass dependencies through the constructor. This ensures your classes are decoupled from the service locator and easy to unit test.

```dart
// ✅ GOOD: Decoupled and testable
class UserRepository implements IUserRepository {
  final ApiClient apiClient;
  UserRepository({required this.apiClient});
}

// ❌ BAD: Hard dependency on service locator
class UserRepository implements IUserRepository {
  final apiClient = getIt<ApiClient>(); 
}
```

## Handling Async Initialization

If some services require async setup, ensure they are ready before the app starts or before accessing them.

### 1. Wait for All Dependencies in `main()`
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies(DevConfig()); 
  
  // Wait for all async singletons (like RemoteConfigService)
  await getIt.allReady(); 
  
  runApp(const MyApp());
}
```

### 2. Wait in the UI (Splash Screen Pattern)
If you want to show a loading screen while dependencies are being initialized:
```dart
FutureBuilder(
  future: getIt.allReady(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      return const HomeScreen();
    }
    return const SplashScreen(); // Show while loading
  },
);
```

## Workflow

### Task Progress
- [ ] **Step 1: Add dependency.** Update `pubspec.yaml` and run `flutter pub get`.
- [ ] **Step 2: Create Injection File.** Setup `lib/core/di/injection.dart`.
- [ ] **Step 3: Define Interfaces.** Use abstract classes for services and repositories.
- [ ] **Step 4: Register Dependencies.** Add singletons and factories to the configuration function.
- [ ] **Step 5: Initialize in main().** Call and await your configuration function.
- [ ] **Step 6: Inject in UI.** Retrieve top-level dependencies (like ViewModels) in your widgets.

## Example

### UI Integration with ListenableBuilder

```dart
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the factory-registered ViewModel
    final viewModel = getIt<UserViewModel>();

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => Text(viewModel.userName),
    );
  }
}
```
