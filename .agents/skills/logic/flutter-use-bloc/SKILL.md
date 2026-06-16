---
name: flutter-use-bloc
description: Use the BLoC pattern for predictable state management in Flutter. Use to separate business logic from UI, handle complex state transitions, and ensure strict immutability.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Wed, 12 Jun 2024 18:00:00 GMT
---
# State Management with BLoC

## Contents
- [Dependencies](#dependencies)
- [Naming Conventions](#naming-conventions)
- [Base State Pattern](#base-state-pattern)
- [Abstract BLoC Pattern](#abstract-bloc-pattern)
- [Dependency Injection with GetIt](#dependency-injection-with-getit)
- [Handling Errors with onError](#handling-errors-with-onerror)
- [Consuming BLoCs in UI](#consuming-blocs-in-ui)
- [Best Practices](#best-practices)
- [Workflow](#workflow)
- [Example](#example)

## Dependencies

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_bloc: ^8.1.5
  bloc: ^8.1.4

dev_dependencies:
  freezed: ^2.5.2
  build_runner: ^2.4.9
```

## Naming Conventions

Maintain consistency across your BLoC implementations to ensure readability and predictability.

- **Events**: Name events in the **past tense** to describe what happened in the UI and end with "Event" (e.g., `UserStartedEvent`, `LoginButtonPressedEvent`, `RefreshRequestedEvent`).
- **Event Handlers**: Name handler methods using the `_on` prefix followed by the event name (e.g., `_onUserStartedEvent`, `_onRefreshRequestedEvent`).
- **States**: Use descriptive nouns to represent the current status (e.g., `UserLoadSuccessState`, `InitialState`).

## Base State Pattern

Use Dart 3 sealed classes to define a standardized set of states for any operation. This avoids redefining `Loading` or `Error` for every feature.

```dart
part of 'base_bloc.dart';
sealed class BaseState<T> {
  final T? data;
  const BaseState({this.data});
}

class InitialState<T> extends BaseState<T> {}

class LoadingState<T> extends BaseState<T> {}

class ProgressState<T> extends BaseState<T> {
  final double progress; // 0.0 to 1.0
  ProgressState(this.progress);
}

class ProcessingState<T> extends BaseState<T> {
  final String message;
  ProcessingState(this.message);
}

class SuccessState<T> extends BaseState<T> {
  SuccessState({super.data});
}

class FailureState<T> extends BaseState<T> {
  final String message;
  FailureState(this.message);
}
```

## Abstract BLoC Pattern

Encapsulate common logic (like API calls) in an abstract BLoC to reduce boilerplate in concrete implementations.

```dart
part 'base_state.dart';
abstract class BaseAppBloc<E, T> extends Bloc<E, BaseState<T>> {
  BaseAppBloc() : super(InitialState());

  /// Helper to handle the standard async lifecycle
  Future<void> handleOperation(Future<T> Function() operation) async {
    emit(LoadingState());
    try {
      final data = await operation();
      emit(SuccessState(data: data));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(FailureState(e.toString()));
    }
  }
}
```

## Dependency Injection with GetIt

Use `get_it` to provide dependencies to your BLoCs via **Constructor Injection**. This makes your BLoCs testable by allowing you to inject mocks.

```dart
// lib/features/users/bloc/user_bloc.dart
class UserBloc extends BaseAppBloc<UserEvent, List<User>> {
  final IUserRepository repository; // Dependency injected via constructor

  UserBloc({required this.repository}) : super() {
    on<UserStartedEvent>(_onUserStartedEvent);
  }

  Future<void> _onUserStartedEvent(UserStartedEvent event, Emitter<BaseState<List<User>>> emit) async {
    await handleOperation(() => repository.getUsers());
  }
}
```

## Handling Errors with onError

Override the `onError` method to centralize error logging and reporting (e.g., to Sentry or Firebase Crashlytics).

```dart
class UserBloc extends BaseAppBloc<UserEvent, List<User>> {
  // ... constructor and handlers

  @override
  void onError(Object error, StackTrace stackTrace) {
    // Log to external service
    logService.recordError(error, stackTrace);
    super.onError(error, stackTrace);
  }
}
```

## Consuming BLoCs in UI

### 1. BlocProvider
Inject your BLoC into the widget tree and use `getIt` to resolve its dependencies.

```dart
BlocProvider(
  create: (context) => getIt<UserBloc>(),
  child: const UserListScreen(),
)
```

### 2. BlocBuilder & Switch Expressions
Use Dart 3 switch expressions for clean, exhaustive state handling.

```dart
BlocBuilder<UserBloc, BaseState<List<User>>>(
  builder: (context, state) {
    return switch (state) {
      InitialState() => const SizedBox(),
      LoadingState() => const CircularProgressIndicator(),
      SuccessState(data: var users) => UserListView(users: users),
      FailureState(message: var msg) => ErrorWidget(msg),
      _ => const SizedBox(),
    };
  },
)
```

## Best Practices

- **Sealed Classes**: Always use `sealed` for states to benefit from exhaustive switch checks.
- **Immutability**: Use `freezed` for complex states that require `copyWith`.
- **BlocSelector**: Use `BlocSelector` instead of `BlocBuilder` when you only need to rebuild for a specific field in the state.
- **BlocObserver**: Implement a global `BlocObserver` for centralized logging and error tracking.

## Workflow

### Task Progress
- [ ] **Step 1: Add dependencies.** Update `pubspec.yaml`.
- [ ] **Step 2: Define Base States.** Create your generic `BaseState<T>` if not already present.
- [ ] **Step 3: Implement Events.** Define events using past tense names.
- [ ] **Step 4: Create Concrete BLoC.** Extend `BaseAppBloc` or `Bloc`, use constructor injection, and implement handlers with the `_on` prefix.
- [ ] **Step 5: Register BLoC.** Add the BLoC to your dependency injection setup if needed.
- [ ] **Step 6: Provide the BLoC.** Wrap the UI with `BlocProvider` and resolve dependencies with `getIt`.
- [ ] **Step 7: Build UI.** Use `BlocBuilder` or `BlocSelector` to consume the state.

## Example

### Concrete Data Fetching BLoC

```dart
sealed class UserEvent {}
class UserStartedEvent extends UserEvent {}

class UserBloc extends BaseAppBloc<UserEvent, List<User>> {
  final IUserRepository repository;

  UserBloc({required this.repository}) {
    on<UserStartedEvent>(_onUserStartedEvent);
  }

  Future<void> _onUserStartedEvent(
    UserStartedEvent event,
    Emitter<BaseState<List<User>>> emit,
  ) {
    return handleOperation(() => repository.getUsers());
  }
}
```
