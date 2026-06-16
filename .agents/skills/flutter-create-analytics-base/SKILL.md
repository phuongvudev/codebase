---
name: flutter-create-analytics-base
description: Build a provider-agnostic analytics base layer in Flutter. Use when adding event tracking, screen view logging, or user identification to a feature without coupling to a specific analytics SDK (Firebase, Amplitude, Mixpanel, etc.).
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Mon, 16 Jun 2026 00:00:00 GMT
---
# Analytics Base Layer

## Contents
- [When to Use](#when-to-use)
- [Architecture Guidance](#architecture-guidance)
- [Package Structure](#package-structure)
- [Domain Layer](#domain-layer)
- [BLoC Layer](#bloc-layer)
- [Implementing an Adapter](#implementing-an-adapter)
- [Workflow](#workflow)
- [Example](#example)

## When to Use

Use this skill when you need to:
- Track custom named events with typed parameters.
- Log screen views with optional context parameters.
- Identify users and set user-level properties.
- Reset analytics state on logout.
- Support multiple analytics back-ends simultaneously (e.g., Firebase + Amplitude) through the Adapter pattern.

Treat analytics as cross-cutting infrastructure, **not** as a direct UI concern.

## Architecture Guidance

Follow Clean Architecture + Feature-First:

- **Domain**: Define `AbstractAnalyticsHandler` and value-object types (`AnalyticsEvent`, `AnalyticsUser`).
- **Data**: Implement the contract with concrete adapters (e.g., `FirebaseAnalyticsAdapter`, `CompositeAnalyticsAdapter`).
- **Presentation / BLoC**: Dispatch `AnalyticsBlocEvent` commands; the BLoC delegates to the handler contract.

Avoid calling analytics SDKs directly inside widgets or use-cases.

Example domain contract:

```dart
abstract interface class AbstractAnalyticsHandler {
  Future<void> trackEvent(AnalyticsEvent event);
  Future<void> trackScreen(String screenName, {Map<String, Object?>? parameters});
  Future<void> identify(AnalyticsUser user);
  Future<void> reset();
}
```

## Package Structure

```
packages/analytic_base/
├── lib/
│   ├── analytic_base.dart          # barrel export
│   └── src/
│       ├── core/
│       │   ├── abstract_analytics_handler.dart
│       │   ├── analytics_event.dart
│       │   └── analytics_user.dart
│       └── bloc/
│           ├── analytics_bloc.dart
│           ├── analytics_bloc_data.dart
│           └── analytics_bloc_event.dart
├── pubspec.yaml
└── analysis_options.yaml
```

## Domain Layer

### AnalyticsEvent

```dart
final class AnalyticsEvent {
  const AnalyticsEvent({
    required this.name,
    this.parameters = const {},
  });

  final String name;
  final Map<String, Object?> parameters;
}
```

### AnalyticsUser

```dart
final class AnalyticsUser {
  const AnalyticsUser({
    required this.userId,
    this.properties = const {},
  });

  final String userId;
  final Map<String, Object?> properties;
}
```

### AbstractAnalyticsHandler

```dart
abstract interface class AbstractAnalyticsHandler {
  Future<void> trackEvent(AnalyticsEvent event);
  Future<void> trackScreen(String screenName, {Map<String, Object?>? parameters});
  Future<void> identify(AnalyticsUser user);
  Future<void> reset();
}
```

## BLoC Layer

### AnalyticsBlocEvent (commands)

```dart
sealed class AnalyticsBlocEvent {
  const AnalyticsBlocEvent();
}

final class TrackAnalyticsEventRequested extends AnalyticsBlocEvent {
  const TrackAnalyticsEventRequested(this.event);
  final AnalyticsEvent event;
}

final class TrackAnalyticsScreenRequested extends AnalyticsBlocEvent {
  const TrackAnalyticsScreenRequested(this.screenName, {this.parameters});
  final String screenName;
  final Map<String, Object?>? parameters;
}

final class IdentifyAnalyticsUserRequested extends AnalyticsBlocEvent {
  const IdentifyAnalyticsUserRequested(this.user);
  final AnalyticsUser user;
}

final class ResetAnalyticsRequested extends AnalyticsBlocEvent {
  const ResetAnalyticsRequested();
}
```

### AnalyticsBlocData (results)

```dart
sealed class AnalyticsBlocData {
  const AnalyticsBlocData();
}

final class AnalyticsEventTracked extends AnalyticsBlocData {
  const AnalyticsEventTracked({required this.event});
  final AnalyticsEvent event;
}

final class AnalyticsScreenTracked extends AnalyticsBlocData {
  const AnalyticsScreenTracked({required this.screenName});
  final String screenName;
}

final class AnalyticsUserIdentified extends AnalyticsBlocData {
  const AnalyticsUserIdentified({required this.user});
  final AnalyticsUser user;
}

final class AnalyticsResetCompleted extends AnalyticsBlocData {
  const AnalyticsResetCompleted();
}
```

## Implementing an Adapter

Create adapters in the feature or app layer, **not** inside `analytic_base`:

```dart
final class FirebaseAnalyticsAdapter implements AbstractAnalyticsHandler {
  const FirebaseAnalyticsAdapter(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> trackEvent(AnalyticsEvent event) =>
      _analytics.logEvent(name: event.name, parameters: event.parameters);

  @override
  Future<void> trackScreen(String screenName, {Map<String, Object?>? parameters}) =>
      _analytics.logScreenView(screenName: screenName);

  @override
  Future<void> identify(AnalyticsUser user) =>
      _analytics.setUserId(id: user.userId);

  @override
  Future<void> reset() => _analytics.resetAnalyticsData();
}
```

For multiple back-ends, use a composite adapter:

```dart
final class CompositeAnalyticsAdapter implements AbstractAnalyticsHandler {
  const CompositeAnalyticsAdapter(this._handlers);

  final List<AbstractAnalyticsHandler> _handlers;

  @override
  Future<void> trackEvent(AnalyticsEvent event) async {
    for (final h in _handlers) {
      await h.trackEvent(event);
    }
  }

  // ... repeat for other methods
}
```

## Workflow

**Task Progress:**
- [ ] 1. Add `analytic_base` path dependency in the consuming package's `pubspec.yaml`.
- [ ] 2. Register `AbstractAnalyticsHandler` binding in GetIt (bind to your concrete adapter).
- [ ] 3. Create your concrete adapter class implementing `AbstractAnalyticsHandler`.
- [ ] 4. Provide `AnalyticsBloc` through `BlocProvider` where needed (e.g., in the app root or a feature entry point).
- [ ] 5. Dispatch `TrackAnalyticsEventRequested` / `TrackAnalyticsScreenRequested` from BLoCs or route observers.
- [ ] 6. Dispatch `IdentifyAnalyticsUserRequested` after successful login.
- [ ] 7. Dispatch `ResetAnalyticsRequested` on logout.
- [ ] 8. Add widget tests verifying that the correct BLoC events are dispatched on key user interactions.

## Example

### Route Observer (automatic screen tracking)

```dart
class AnalyticsRouteObserver extends NavigatorObserver {
  AnalyticsRouteObserver(this._bloc);

  final AnalyticsBloc _bloc;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name;
    if (name != null) {
      _bloc.add(TrackAnalyticsScreenRequested(name));
    }
  }
}
```

### BLoC event dispatch from a feature BLoC

```dart
Future<void> _onLoginSuccess(
  LoginSuccess event,
  Emitter<BaseState<LoginData>> emit,
) async {
  analyticsBloc.add(
    IdentifyAnalyticsUserRequested(
      AnalyticsUser(userId: event.userId),
    ),
  );
}
```
