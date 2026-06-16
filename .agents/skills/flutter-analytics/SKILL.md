---
name: flutter-analytics
description: Build a provider-agnostic analytics base layer in Flutter. Use when adding event tracking, screen view logging, or user identification to a feature without coupling to a specific analytics SDK (Firebase, Amplitude, Mixpanel, etc.).
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Mon, 16 Jun 2026 00:00:00 GMT
---
# Analytics Feature Implementation

## Contents
- [Resolving Problem](#resolving-problem)
- [Input](#input)
- [Plan](#plan)
- [Estimation](#estimation)
- [Acceptance Criteria](#acceptance-criteria)
- [Advantages](#advantages)
- [Disadvantages](#disadvantages)
- [Architecture Guidance](#architecture-guidance)
- [Package Structure](#package-structure)
- [Domain Layer](#domain-layer)
- [BLoC Layer](#bloc-layer)
- [Implementing an Adapter](#implementing-an-adapter)
- [Workflow](#workflow)
- [Example](#example)

---

## Resolving Problem

Analytics is a cross-cutting concern that is often implemented by calling SDK methods directly from widgets or use-cases. This creates tight coupling to a specific vendor, pollutes business logic with tracking code, makes unit testing difficult, and causes painful migrations when changing analytics providers.

**Problems this skill solves:**

| Problem | Solution |
|---|---|
| Direct SDK calls scattered across widgets | Centralized `AbstractAnalyticsHandler` contract in the domain layer |
| Tight coupling to one vendor (e.g., Firebase) | Adapter pattern — swap providers without touching feature code |
| Untestable analytics calls | BLoC commands are plain Dart events, fully unit-testable |
| Duplicate tracking logic per feature | Shared `AnalyticsBloc` used by all features through GetIt |
| No screen-view tracking | `AnalyticsRouteObserver` hooks into the navigator lifecycle |
| Analytics state not reset on logout | `ResetAnalyticsRequested` event clears user identity |

---

## Input

Before starting the implementation, ensure the following are available:

- [ ] **Feature requirement**: Which events must be tracked (name, parameters).
- [ ] **Analytics provider**: Firebase, Amplitude, Mixpanel, or a custom back-end.
- [ ] **User identity model**: The user fields to forward (user ID, role, plan, etc.).
- [ ] **Screen list**: All named routes or screens to auto-track.
- [ ] **GetIt setup**: A working `ServiceLocator` / `injection.dart` file.
- [ ] **BLoC base**: `BaseAppBloc` and `BaseState<T>` are already defined.
- [ ] **Provider SDK**: The analytics SDK package added to `pubspec.yaml`.

---

## Plan

### Phase 1 — Domain (shared infrastructure)
1. Create `packages/analytic_base/` as an internal package (or `lib/core/analytics/`).
2. Define `AnalyticsEvent` and `AnalyticsUser` value objects.
3. Define `AbstractAnalyticsHandler` interface.

### Phase 2 — BLoC layer
4. Define `AnalyticsBlocEvent` sealed class with track-event, track-screen, identify, and reset commands.
5. Define `AnalyticsBlocData` sealed class with corresponding result types.
6. Implement `AnalyticsBloc` delegating every command to `AbstractAnalyticsHandler`.

### Phase 3 — Data / Adapter layer
7. Implement a concrete adapter (e.g., `FirebaseAnalyticsAdapter`) in the app or feature layer.
8. Optionally, wrap multiple adapters in `CompositeAnalyticsAdapter`.

### Phase 4 — Dependency Injection
9. Register `AbstractAnalyticsHandler` → concrete adapter in GetIt.
10. Register `AnalyticsBloc` as a singleton in GetIt.

### Phase 5 — Integration
11. Provide `AnalyticsBloc` via `BlocProvider` at the app root.
12. Add `AnalyticsRouteObserver` to `MaterialApp.navigatorObservers`.
13. Dispatch `IdentifyAnalyticsUserRequested` after login.
14. Dispatch `ResetAnalyticsRequested` on logout.
15. Add feature-level event dispatches from feature BLoCs.

### Phase 6 — Verification
16. Write unit tests for each BLoC event handler.
17. Write widget tests verifying dispatches on key user interactions.

---

## Estimation

| Phase | Task | Estimate |
|---|---|---|
| 1 | Domain layer (models + interface) | 1 h |
| 2 | BLoC layer (events + data + bloc) | 2 h |
| 3 | Concrete adapter implementation | 1–2 h per provider |
| 4 | Dependency injection wiring | 0.5 h |
| 5 | App-level integration (observer, login/logout hooks) | 1 h |
| 5 | Per-feature event dispatches | 0.5 h per feature |
| 6 | Unit + widget tests | 2–3 h |
| **Total** | **New project** | **~8–12 h** |
| **Total** | **Adding to existing project** | **~4–6 h** |

> Estimates assume a single analytics provider. Add ~1–2 h per additional provider using `CompositeAnalyticsAdapter`.

---

## Acceptance Criteria

- [ ] All analytics calls go through `AbstractAnalyticsHandler`; no feature code imports an analytics SDK directly.
- [ ] `AnalyticsBloc` is registered as a singleton in GetIt and provided at the app root via `BlocProvider`.
- [ ] Every named route triggers a `TrackAnalyticsScreenRequested` event via `AnalyticsRouteObserver`.
- [ ] `IdentifyAnalyticsUserRequested` is dispatched immediately after a successful login.
- [ ] `ResetAnalyticsRequested` is dispatched on logout, and the analytics user identity is cleared.
- [ ] Adding a new analytics provider requires only a new adapter class — no changes to feature BLoCs or UI.
- [ ] Unit tests cover every `AnalyticsBlocEvent` handler using a mock `AbstractAnalyticsHandler`.
- [ ] Widget tests verify that tapping key CTAs dispatches the correct `AnalyticsBlocEvent`.
- [ ] CI passes with no new lint warnings or failing tests.

---

## Advantages

- **Vendor-agnostic**: Changing from Firebase Analytics to Amplitude requires only a new adapter — zero changes to feature code.
- **Testable**: BLoC commands are plain Dart sealed-class instances; mock the handler and assert events in pure unit tests.
- **Centralized control**: One place to add global enrichment (e.g., append `appVersion` to every event).
- **Separation of concerns**: Feature BLoCs remain ignorant of which analytics platform is in use.
- **Composable**: Multiple providers can run simultaneously through `CompositeAnalyticsAdapter`.
- **Auto screen tracking**: `AnalyticsRouteObserver` eliminates per-screen boilerplate.
- **Consistent reset**: `ResetAnalyticsRequested` guarantees user identity is cleared on every provider simultaneously.

---

## Disadvantages

- **Abstraction overhead**: An extra layer (interface + adapter) compared to calling the SDK directly — higher initial setup cost.
- **Delayed parameter validation**: Typed `AnalyticsEvent` cannot enforce provider-specific parameter constraints at compile time.
- **Async fire-and-forget**: Tracking calls in `AnalyticsBloc` are not awaited by the UI; transient failures are silently swallowed unless you add explicit error handling.
- **Package boundary**: Placing `analytic_base` in a separate package adds `pubspec.yaml` maintenance overhead for monorepo setups.
- **Learning curve**: New team members must understand the Adapter + BLoC indirection before contributing analytics calls.

---

## Architecture Guidance

Follow Clean Architecture + Feature-First:

- **Domain**: `AbstractAnalyticsHandler` interface and value-object types (`AnalyticsEvent`, `AnalyticsUser`).
- **Data**: Concrete adapters implementing the contract (e.g., `FirebaseAnalyticsAdapter`, `CompositeAnalyticsAdapter`).
- **Presentation / BLoC**: `AnalyticsBloc` dispatches `AnalyticsBlocEvent` commands and delegates to the handler.

Avoid calling analytics SDKs directly inside widgets or use-cases.

---

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

---

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

---

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

---

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

  @override
  Future<void> trackScreen(String screenName, {Map<String, Object?>? parameters}) async {
    for (final h in _handlers) {
      await h.trackScreen(screenName, parameters: parameters);
    }
  }

  @override
  Future<void> identify(AnalyticsUser user) async {
    for (final h in _handlers) {
      await h.identify(user);
    }
  }

  @override
  Future<void> reset() async {
    for (final h in _handlers) {
      await h.reset();
    }
  }
}
```

---

## Workflow

**Task Progress:**
- [ ] 1. Verify all [Input](#input) items are available.
- [ ] 2. Create domain models (`AnalyticsEvent`, `AnalyticsUser`) and `AbstractAnalyticsHandler`.
- [ ] 3. Implement `AnalyticsBlocEvent`, `AnalyticsBlocData`, and `AnalyticsBloc`.
- [ ] 4. Add `analytic_base` path dependency in the consuming package's `pubspec.yaml`.
- [ ] 5. Implement the concrete adapter(s) in the app layer.
- [ ] 6. Register `AbstractAnalyticsHandler` and `AnalyticsBloc` in GetIt.
- [ ] 7. Provide `AnalyticsBloc` via `BlocProvider` at the app root.
- [ ] 8. Add `AnalyticsRouteObserver` to `MaterialApp.navigatorObservers`.
- [ ] 9. Dispatch `IdentifyAnalyticsUserRequested` after successful login.
- [ ] 10. Dispatch `ResetAnalyticsRequested` on logout.
- [ ] 11. Add feature-level event dispatches from feature BLoCs.
- [ ] 12. Write unit and widget tests, verify all [Acceptance Criteria](#acceptance-criteria) are met.

---

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

### Custom event dispatch

```dart
analyticsBloc.add(
  TrackAnalyticsEventRequested(
    AnalyticsEvent(
      name: 'purchase_completed',
      parameters: {
        'product_id': product.id,
        'price': product.price,
        'currency': 'USD',
      },
    ),
  ),
);
```
