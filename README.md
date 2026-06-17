# Senior Flutter Engineer Codebase

## 🌟 Introduction
Welcome to the **Senior Flutter Engineer** codebase. This project serves as a production-grade template and playground for building scalable, high-performance, and maintainable Flutter applications. Our mission is to demonstrate "Production-First" engineering principles, where type-safety, modularity, and automated verification are not afterthoughts but core requirements.

This repository is optimized for **specialized AI agents** to collaborate with human engineers, ensuring that every architectural decision follows a hybrid **Clean Architecture + Feature-First** approach.

---

## 🚀 Tech Stack & Core Philosophy
We utilize a modern, industry-standard tech stack (2024-2025) to ensure maximum reliability and developer velocity:

- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) with Dart 3 sealed classes for predictable state transitions.
- **Dependency Injection**: [get_it](https://pub.dev/packages/get_it) for decoupled, interface-based service location.
- **Networking**: [dio](https://pub.dev/packages/dio) + [retrofit](https://pub.dev/packages/retrofit) for type-safe API consumption.
- **Routing**: [go_router](https://pub.dev/packages/go_router) with a modular, decentralized registration system.
- **Responsive UI**: Custom `BaseResponsiveScreen` system for seamless adaptivity across mobile, tablet, and desktop.
- **Localization**: Type-safe `S` class generation via `intl_utils`.
- **Sitemap**: Automated codebase indexing via `flutter-scan-codebase-sitemap`.
- **Workflow Handoff**: Post-implementation tracking via `flutter-task-management-followup` (PR + task + comment + note).

---

## 🏗️ Hybrid Architecture
We combine **Clean Architecture** (isolation of concerns) with a **Feature-First** structure (ease of discovery).

```text
lib/src/
  ├── core/                # Shared foundational logic (Base classes, Network, Router)
  └── features/            # Feature-specific modules
      └── feature_name/
          ├── domain/      # Business Logic (Entities, Use Cases, Repositories Interfaces)
          ├── data/        # Implementation (DTOs, Repositories, Data Sources)
          └── presentation/ # UI (Screens, Widgets, BLoCs)
```

---

## 📖 How to Build a New Feature
Follow this standardized 3-step workflow to implement any new functionality.

### Step 1: Domain Layer (The Contract)
Define your data models (Entities) and the repository interface.
```dart
// lib/src/features/profile/domain/profile.dart
class Profile {
  final String id;
  final String name;
  const Profile({required this.id, required this.name});
}

// lib/src/features/profile/domain/profile_repository.dart
abstract class ProfileRepository {
  Future<Result<Profile>> getProfile();
}
```

### Step 2: Data Layer (The Implementation)
Implement the repository and define the Retrofit API client.
```dart
// lib/src/features/profile/data/profile_api.dart
@RestApi()
abstract class ProfileApi {
  @GET('/user/profile')
  Future<ProfileDto> getProfile();
}
```

### Step 3: Presentation Layer (The UI & Logic)
Create your BLoC by extending `BaseAppBloc` and your screen by extending `BaseResponsiveScreen`.

#### 1. Logic (BLoC)
```dart
class ProfileBloc extends BaseAppBloc<ProfileEvent, Profile> {
  final ProfileRepository repository;
  ProfileBloc(this.repository);

  Future<void> _onLoad(LoadEvent event, Emitter emit) async {
    emit(const LoadingState());
    final result = await repository.getProfile();
    result.fold(
      (success) => emit(SuccessState(data: success)),
      (failure) => emit(FailureState(failure.message)),
    );
  }
}
```

#### 2. UI (Screen)
```dart
class ProfileScreen extends BaseResponsiveScreen {
  @override
  Widget buildMobile(BuildContext context) {
    return BlocBuilder<ProfileBloc, BaseState<Profile>>(
      builder: (context, state) {
        if (state is SuccessState<Profile>) {
          return Text('Hello, ${state.data?.name}');
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
```

---

## ✨ Core Components Guide

### 🧱 State Management (`BaseState`)
We use a sealed class `BaseState<T>` to handle all common UI states consistently:
- `InitialState`: The default starting state.
- `LoadingState`: For background/async operations.
- `SuccessState<T>`: Contains the typed data.
- `FailureState`: Contains the error message.

### 📱 Responsive UI (`BaseResponsiveScreen`)
Avoid manual `MediaQuery` checks. Simply override the builds you need:
- `buildSmallScreen(context)`
- `buildMediumScreen(context)` (Optional - defaults to Mobile)
- `buildLargeScreen(context)` (Optional - defaults to Tablet)

### 🛣️ Routing (`AppRouteModule`)
Register new features in the router without touching the core `AppRouter`:
1. Create a `FeatureRouteModule`.
2. Define paths in `AppRoutes`.
3. Add the module to `AppRouterFactory`.

---

## 🚀 Advanced Usage Patterns

### 🛡️ Functional Error Handling
We avoid throwing exceptions in the domain and presentation layers. Instead, we use the `Result<T>` pattern.

#### The `Result` Pattern
```dart
Future<Result<Profile>> getProfile() async {
  return executeOrFailure(() => _remoteDataSource.getProfile());
}

// Consuming in BLoC
final result = await repository.getProfile();
result.fold(
  (success) => emit(SuccessState(data: success)),
  (failure) => emit(FailureState(failure.message)),
);
```
- **`executeOrFailure`**: A core utility that catches network/parse exceptions and converts them into typed `Failure` objects.

### 💉 Type-Safe Dependency Injection
We use **GetIt** for service location but prioritize **Constructor Injection** for testability.

#### Registration
```dart
final getIt = GetIt.instance;

void setupDependencies() {
  // Data Sources
  getIt.registerLazySingleton<ProfileApi>(() => ProfileApi(getIt<Dio>()));
  
  // Repositories (Interface binding)
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(getIt<ProfileApi>()),
  );
  
  // BLoCs (Factory)
  getIt.registerFactory(() => ProfileBloc(getIt<ProfileRepository>()));
}
```

### 🛣️ Advanced Modular Routing
Each feature manages its own routes and logic via `AppRouteModule`.

#### Redirection & Deep Linking
```dart
class AuthRouteModule extends AppRouteModule {
  @override
  RouteModuleOptions get options => RouteModuleOptions(
    initialLocation: '/login',
    redirect: (context, state) {
      if (!isLoggedIn && state.matchedLocation != '/login') return '/login';
      return null;
    },
    deepLinks: [
      DeepLinkMatcher.pathPrefix('/auth'),
    ],
  );
}
```

### 📱 Adaptive Layouts (Deep Dive)
The `BaseResponsiveScreen` provides a clean API for handling different form factors.

#### Breakpoint Customization
Use `ScreenBreakpointBuilder` for fine-grained control within a widget:
```dart
Widget build(BuildContext context) {
  return ScreenBreakpointBuilder(
    smallBuilder: (context) => const MobileLayout(),
    mediumBuilder: (context) => const TabletLayout(),
    largeBuilder: (context) => const DesktopLayout(),
  );
}
```

---

## 🤖 AI-Powered Workflow
This codebase is designed to work with specialized **Agents**. To use them:
1. Load a skill (e.g., `Activate Skill: flutter-use-bloc`).
2. Provide the requirements.
3. The agent will generate code following the patterns defined in `AGENTS.md`.

---

## ✅ Quality & Testing
Keep the codebase healthy by running these commands before every commit:

```bash
# Run all unit and widget tests
flutter test

# Run linter
flutter analyze

# Generate code (Retrofit, BLoC, etc.)
dart run build_runner build --delete-conflicting-outputs
```
