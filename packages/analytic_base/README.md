# analytic_base

A Flutter package for provider-agnostic, architecture-first analytics tracking.

## Overview

`analytic_base` provides a stable domain contract and BLoC layer that decouples your application's event tracking, screen logging, and user identification from any specific analytics SDK (Firebase Analytics, Amplitude, Mixpanel, etc.).

It uses the **Adapter Pattern** to define a consistent `AbstractAnalyticsHandler` interface and **BLoC** for predictable state management — keeping analytics calls out of your widgets.

## Features

- **Decoupled Architecture**: Interface-driven design using `AbstractAnalyticsHandler`.
- **Event Tracking**: Track named events with typed `Map<String, Object?>` parameters.
- **Screen Tracking**: Log screen views with optional context parameters.
- **User Identification**: Identify users with a `userId` and arbitrary properties.
- **Reset Support**: Clear analytics state on logout via `reset()`.
- **Composite Adapters**: Fan out to multiple backends from a single handler.
- **BLoC Integration**: Predictable, testable state management for all analytics operations.

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  analytic_base:
    path: packages/analytic_base
```

## Usage

### 1. Implement a concrete adapter

Create an adapter in your app or feature layer that implements `AbstractAnalyticsHandler`:

```dart
import 'package:analytic_base/analytic_base.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

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

### 2. Register the adapter in GetIt

```dart
import 'package:get_it/get_it.dart';
import 'package:analytic_base/analytic_base.dart';

void setupAnalytics() {
  getIt.registerLazySingleton<AbstractAnalyticsHandler>(
    () => FirebaseAnalyticsAdapter(FirebaseAnalytics.instance),
  );
}
```

### 3. Dispatch BLoC events

```dart
// Track a named event
context.read<AnalyticsBloc>().add(
  TrackAnalyticsEventRequested(
    AnalyticsEvent(name: 'button_tapped', parameters: {'screen': 'home'}),
  ),
);

// Track a screen view
context.read<AnalyticsBloc>().add(
  TrackAnalyticsScreenRequested('HomeScreen'),
);

// Identify the user after login
context.read<AnalyticsBloc>().add(
  IdentifyAnalyticsUserRequested(
    AnalyticsUser(userId: 'user-123', properties: {'plan': 'premium'}),
  ),
);

// Reset on logout
context.read<AnalyticsBloc>().add(const ResetAnalyticsRequested());
```

### 4. Automatic screen tracking via route observer

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

## Architecture

- **Core**: `AbstractAnalyticsHandler` contract, `AnalyticsEvent`, and `AnalyticsUser` value objects.
- **BLoC**: `AnalyticsBloc` manages all analytics operations and emits typed `AnalyticsBlocData` results.
- **Adapters**: Implemented outside this package — one per analytics SDK or a composite.
