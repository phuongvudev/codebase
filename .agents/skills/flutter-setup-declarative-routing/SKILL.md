---
name: flutter-setup-declarative-routing
description: Configure `MaterialApp.router` using a package like `go_router` for advanced URL-based navigation. Use when developing web applications or mobile apps that require specific deep linking and browser history support.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Wed, 12 Jun 2024 11:00:00 GMT
---
# Implementing Abstract Routing, Deep Linking, and Module Reuse

## Contents
- [Core Concepts](#core-concepts)
- [Best Practices: Route Constants](#best-practices-route-constants)
- [Workflow: Designing an Abstract Router](#workflow-designing-an-abstract-router)
- [Workflow: Defining Route Modules and Config Options](#workflow-defining-route-modules-and-config-options)
- [Workflow: Initializing the Application and Router](#workflow-initializing-the-application-and-router)
- [Workflow: Configuring Platform Deep Linking](#workflow-configuring-platform-deep-linking)
- [Workflow: Implementing Nested Navigation](#workflow-implementing-nested-navigation)
- [Examples](#examples)

## Core Concepts

Use the `go_router` package for declarative routing in Flutter. It provides a robust API for complex routing scenarios, deep linking, and nested navigation. 

- **GoRouter**: The central configuration object defining the application's route tree.
- **GoRoute**: A standard route mapping a URL path to a Flutter screen.
- **ShellRoute / StatefulShellRoute**: Wraps child routes in a persistent UI shell (e.g., a `BottomNavigationBar`). `StatefulShellRoute` maintains the state of parallel navigation branches.
- **Path URL Strategy**: Removes the default `#` fragment from web URLs, essential for clean deep linking across platforms.
- **Abstract Router**: A reusable router composition layer that merges route modules and centralizes `initialLocation`, `redirect`, and deep link parsing.
- **Route Module**: A self-contained routing unit that owns its own paths, redirects, initial entry point, and deep link rules.

## Best Practices: Route Constants

Avoid hardcoding strings in your navigation logic. Define a central class for route names and paths.

```dart
class AppRoutes {
  static const String home = '/';
  static const String homeName = 'home';

  static const String details = 'details/:id';
  static const String detailsName = 'details';

  // Helper method to build paths with parameters
  static String detailsPath(String id) => '/details/$id';
}
```

## Workflow: Designing an Abstract Router

Model routing as a composition of modules instead of a single hardcoded tree. This keeps features isolated and makes routing reusable across flavors, environments, and app variants.

Recommended responsibilities:

- **Root router**: merges modules and provides the shared `GoRouter` configuration.
- **Module config**: each feature module exposes its own `initialLocation`, `redirect`, and deep link handlers.
- **Route paths**: remain centralized inside the module to avoid duplicated string literals.

Example abstraction:

```dart
abstract class RouteModuleConfig {
  const RouteModuleConfig();

  /// Initial route when this module becomes the entry point.
  String get initialLocation;

  /// Optional module-level redirect logic.
  String? redirect(BuildContext context, GoRouterState state);

  /// Whether the module can resolve this deep link.
  bool supportsDeepLink(Uri uri);

  /// Routes owned by the module.
  List<RouteBase> routes();
}

class AppRouterFactory {
  const AppRouterFactory(this.modules);

  final List<RouteModuleConfig> modules;

  GoRouter create({required String fallbackLocation}) {
    return GoRouter(
      initialLocation: _resolveInitialLocation(fallbackLocation),
      routes: modules.expand((module) => module.routes()).toList(),
      redirect: (context, state) {
        for (final module in modules) {
          final redirect = module.redirect(context, state);
          if (redirect != null) return redirect;
        }
        return null;
      },
    );
  }

  String _resolveInitialLocation(String fallbackLocation) {
    for (final module in modules) {
      if (module.initialLocation.isNotEmpty) {
        return module.initialLocation;
      }
    }
    return fallbackLocation;
  }
}
```

## Workflow: Defining Route Modules and Config Options

Create one routing module per feature or navigation domain. Each module should expose config options so behavior can be enabled or overridden without changing the root router.

Typical module config options:

- **deeplink**: declared path patterns the module can handle.
- **initial**: module-specific entry location, useful for shells or gated flows.
- **redirect**: authentication, onboarding, or environment-based rerouting.

Example feature module:

```dart
class AuthRouteModule extends RouteModuleConfig {
  const AuthRouteModule({
    this.initialLocation = '/login',
    this.enableRedirect = true,
  });

  @override
  final String initialLocation;

  final bool enableRedirect;

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    if (!enableRedirect) return null;

    final isAuthenticated = false; // Replace with auth state lookup.
    final isGoingToLogin = state.matchedLocation == '/login';

    if (!isAuthenticated && !isGoingToLogin) {
      return '/login';
    }

    return null;
  }

  @override
  bool supportsDeepLink(Uri uri) => uri.path.startsWith('/login');

  @override
  List<RouteBase> routes() {
    return [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
    ];
  }
}
```

Use this pattern when:

- a feature is reused in multiple products or flavors,
- the same route set needs different initial paths in dev/prod,
- redirects depend on app state or module-level feature flags,
- deeplink handling must stay isolated from unrelated navigation rules.

## Workflow: Initializing the Application and Router

### 1. Scaffold the Application
```bash
flutter pub add go_router
```

### 2. Configure the Router
Define a top-level `GoRouter` instance. Use `name` and constants for maintainability.

```dart
final GoRouter _router = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      name: AppRoutes.homeName,
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: AppRoutes.details,
          name: AppRoutes.detailsName,
          builder: (context, state) => DetailsScreen(
            id: state.pathParameters['id']!,
          ),
        ),
      ],
    ),
  ],
);
```

## Workflow: Configuring Platform Deep Linking

### Validation Loop
- **Android**: Test using ADB.
  ```bash
  adb shell 'am start -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "https://yourdomain.com/details/123"' com.yourcompany.yourapp
  ```
- **iOS**: Test using `xcrun`.
  ```bash
  xcrun simctl openurl booted https://yourdomain.com/details/123
  ```

## Workflow: Implementing Nested Navigation

Use `StatefulShellRoute` for persistent UI shells.

```dart
final GoRouter _router = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
```

## Examples

### Programmatic Navigation
Always prefer constants or helper methods when navigating.

```dart
void openDetails(BuildContext context) {
  // 1. Using helper methods (Best for complex paths)
  context.go(AppRoutes.detailsPath('123'));

  // 2. Using named routes (Best for simple parameters)
  context.goNamed(
    AppRoutes.detailsName,
    pathParameters: {'id': '123'},
  );

  // 3. Simple navigation
  context.go(AppRoutes.home);
}
```
