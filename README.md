# codebase

A scalable, high-performance Flutter project applying modern architectural patterns and AI-powered development techniques.

## 🚀 Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (2024-2025 optimized)
- **Architecture**: Hybrid **Clean Architecture + Feature-First**
- **State Management**: [BLoC](https://pub.dev/packages/flutter_bloc) with generic `BaseState` pattern
- **Dependency Injection**: [GetIt](https://pub.dev/packages/get_it) service locator
- **Networking**: [Dio](https://pub.dev/packages/dio) + [Retrofit](https://pub.dev/packages/retrofit) for type-safe API clients
- **Routing**: [GoRouter](https://pub.dev/packages/go_router) for declarative, URL-based navigation
- **Permissions**: `permission_handler` with platform-safe abstractions
- **Internationalization**: `intl_utils` for type-safe localization
- **UI Components**: Atomic Design Pattern with Responsive/Adaptive construction

## 🏗️ Architecture

The project follows a **Hybrid Clean Architecture + Feature-First** approach. Modular logic is isolated into layers within each feature:

- **Domain**: Entities, Repositories (interfaces), and Use Cases. Pure Dart, no Flutter dependencies.
- **Data**: Repository implementations, DTOs (Data Transfer Objects), and Data Sources (API clients, Local DB).
- **Presentation**: BLoCs, Screens (using `BaseResponsiveScreen`), and Widgets (Atoms, Molecules, Organisms).

## ✨ Core Features

### What this codebase can do
- Build scalable Flutter features with a hybrid Clean Architecture + Feature-First structure.
- Manage app state with BLoC and reusable base state patterns.
- Resolve dependencies with GetIt for testable, decoupled modules.
- Integrate REST APIs using Dio + Retrofit with generated, type-safe clients.
- Support responsive UI layouts for small and large screens.
- Handle runtime permissions with deterministic permission flows.
- Enable localization with ARB files and generated localization classes.

### Responsive Presentation Layer
The project provides a base foundation for building responsive screens that react to state changes and screen size breakpoints.

```dart
class MyScreen extends BaseResponsiveScreen<MyBloc, MyState> {
  @override
  MyBloc bloc(BuildContext context) => MyBloc();

  @override
  Widget buildSmallScreen(BuildContext context, MyState state) {
    return Scaffold(body: Center(child: Text('Mobile Layout')));
  }

  @override
  Widget buildLargeScreen(BuildContext context, MyState state) {
    return Scaffold(body: Center(child: Text('Desktop Layout')));
  }
}
```

### Deterministic Permission Flow
`PermissionBloc` provides a feature-safe permission flow on top of `AbstractPermissionHandler`.

```dart
final bloc = PermissionBloc(permissionHandler: getIt<AbstractPermissionHandler>());

bloc.add(const RequestPermissionRequested(PermissionType.camera));
```

### Type-Safe Networking
Leverages Retrofit and Dio for declarative API definitions with automated JSON serialization and centralized error handling.

## 🤖 What AI agents can do

AI agents in this repository can accelerate development workflows by:

- Applying architecture best practices for new features and refactors.
- Generating UI components, responsive layouts, and widget state behaviors.
- Setting up and extending BLoC state management flows.
- Implementing networking layers with Dio + Retrofit patterns.
- Wiring and maintaining dependency injection with GetIt.
- Adding localization, permissions, and routing setup.
- Creating widget previews, widget tests, and integration tests.
- Assisting with debugging, error-handling patterns, and iterative improvements.

## 📁 Project Structure

```text
lib/
├── generated/          # Auto-generated files (intl, JSON, etc.)
├── l10n/               # Localization ARB files
├── src/
│   ├── core/           # Shared components (BLoC, Network, Router, etc.)
│   └── features/       # Feature-based modules (Domain, Data, Presentation)
└── codebase.dart       # Public API exports
```

## 🛠️ Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- `build_runner` for code generation

### Setup
1. Clone the repository.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run code generation:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

### Localization
Add new strings to `lib/l10n/app_en.arb` and run `build_runner` or use the Flutter Intl IDE plugin to update generated files.

---

*Built with a "Production-First" mindset.*
