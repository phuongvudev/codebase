---
name: flutter-use-riverpod
description: Use Riverpod for modern, type-safe state management in Flutter. Use when building scalable applications that require context-independent logic and robust handling of asynchronous data.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Wed, 12 Jun 2024 17:00:00 GMT
---
# State Management with Riverpod

## Contents
- [Dependencies](#dependencies)
- [Core Concepts](#core-concepts)
- [Defining Providers (Code Generation)](#defining-providers-code-generation)
- [Consuming Providers in UI](#consuming-providers-in-ui)
- [Handling Asynchronous State](#handling-asynchronous-state)
- [Side Effects & Modifications](#side-effects--modifications)
- [Workflow](#workflow)
- [Example](#example)

## Dependencies

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

dev_dependencies:
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.9
```

## Core Concepts

Riverpod is a reactive caching framework that solves many limitations of Provider.

- **ProviderScope**: Must wrap your root widget to store the state of all providers.
- **ConsumerWidget**: A widget that can listen to providers.
- **WidgetRef**: The object used to interact with providers from a widget (`ref.watch`, `ref.read`).
- **Immutability**: States should always be immutable to ensure predictable updates.

## Defining Providers (Code Generation)

The modern best practice is to use the `@riverpod` annotation. This enables compile-time safety and reduces boilerplate.

### Simple Functional Provider (Read-only)
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'greeting_provider.g.dart';

@riverpod
String greeting(GreetingRef ref) => 'Hello Riverpod!';
```

### Notifier Provider (Mutable State)
Use a class that extends `_$ClassName` to manage state that can change.

```dart
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
}
```

## Consuming Providers in UI

### 1. ConsumerWidget
The most common way to consume state in a widget.

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(greetingProvider);
    return Text(value);
  }
}
```

### 2. Interaction
Use `ref.read` inside callbacks (like `onPressed`) to trigger methods without rebuilding the entire widget.

```dart
ElevatedButton(
  onPressed: () => ref.read(counterProvider.notifier).increment(),
  child: const Text('Increment'),
)
```

## Handling Asynchronous State

Use `AsyncNotifier` to handle data fetching, loading, and error states automatically.

```dart
@riverpod
class UserList extends _$UserList {
  @override
  Future<List<User>> build() async {
    final repository = ref.watch(userRepositoryProvider);
    return repository.fetchUsers();
  }
}
```

### UI Consumption (AsyncValue)
```dart
final userList = ref.watch(userListProvider);

return userList.when(
  data: (users) => ListView(...),
  error: (err, stack) => Text('Error: $err'),
  loading: () => const CircularProgressIndicator(),
);
```

## Side Effects & Modifications

To update state based on user actions (e.g., adding an item to a list):

```dart
Future<void> addUser(User user) async {
  state = const AsyncLoading();
  state = await AsyncValue.guard(() async {
    await repository.saveUser(user);
    final currentList = state.value ?? [];
    return [...currentList, user];
  });
}
```

## Workflow

### Task Progress
- [ ] **Step 1: Add dependencies.** Update `pubspec.yaml` and run `flutter pub get`.
- [ ] **Step 2: Wrap with ProviderScope.** Add `ProviderScope` to your `runApp` call.
- [ ] **Step 3: Define Models.** Create immutable data models (preferably with `freezed`).
- [ ] **Step 4: Create Providers.** Use `@riverpod` annotations for logic and data fetching.
- [ ] **Step 5: Run Code Generation.** Execute `build_runner`.
- [ ] **Step 6: Integrate UI.** Convert widgets to `ConsumerWidget` and use `ref.watch`.

## Example

### Data Fetching with Riverpod

```dart
@riverpod
Future<User> userData(UserDataRef ref, {required String id}) async {
  final api = ref.watch(apiClientProvider);
  return api.getUser(id);
}

// UI usage
class UserProfile extends ConsumerWidget {
  final String userId;
  const UserProfile({required this.userId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userDataProvider(id: userId));

    return userAsync.when(
      data: (user) => Text('Name: ${user.name}'),
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
    );
  }
}
```
