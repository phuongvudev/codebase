---
name: flutter-handle-errors
description: Implement explicit functional error handling in Flutter using the "Result Pattern" and Dart 3 sealed classes. Use to ensure type-safe error management across all architectural layers.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Wed, 12 Jun 2024 22:00:00 GMT
---
# Functional Error Handling with the Result Pattern

## Contents
- [Concepts: Exceptions vs. Failures](#concepts-exceptions-vs-failures)
- [Defining the Result Type](#defining-the-result-type)
- [Layered Responsibilities](#layered-responsibilities)
- [Functional Chaining (Async)](#functional-chaining-async)
- [Global Error Catching](#global-error-catching)
- [Workflow](#workflow)
- [Example](#example)

## Concepts: Exceptions vs. Failures

To maintain a clean architecture, distinguish between technical problems and business logic errors.

*   **Exceptions (Data Layer)**: Unexpected technical errors from external sources (e.g., `DioException`, `SocketException`). They are caught in the Data layer and mapped to custom exceptions.
*   **Failures (Domain/Repository Layer)**: Explicit objects representing a known error state that the UI should handle (e.g., `InvalidCredentialsFailure`, `ServerFailure`).

## Defining the Result Type

Use Dart 3 sealed classes to create a container that explicitly returns either a value or a failure.

```dart
sealed class Result<S, F extends Failure> {
  const Result();
}

class Success<S, F extends Failure> extends Result<S, F> {
  final S data;
  const Success(this.data);
}

class FailureState<S, F extends Failure> extends Result<S, F> {
  final F failure;
  const FailureState(this.failure);
}
```

## Layered Responsibilities

### 1. Data Layer: Catch and Throw
Catch raw library exceptions and throw domain-specific exceptions.

```dart
try {
  final response = await api.get('/user');
  return UserModel.fromJson(response.data);
} on DioException catch (e) {
  throw ServerException(e.message);
}
```

### 2. Repository Layer: Map to Result
Catch exceptions and return a `Result.failure` instead of letting the exception bubble up to the UI.

```dart
Future<Result<User, Failure>> getUser() async {
  try {
    final user = await dataSource.getUser();
    return Success(user);
  } on ServerException catch (e) {
    return FailureState(ServerFailure(e.message));
  }
}
```

### 3. Presentation Layer: Pattern Matching
Use exhaustive switch expressions to handle both success and failure states in the UI.

```dart
final result = await repository.getUser();

return switch (result) {
  Success(data: var user) => UserProfile(user),
  FailureState(failure: var f) => ErrorWidget(f.message),
};
```

## Functional Chaining (Async)

For complex logic requiring multiple sequential calls, use the `fpdart` package's `TaskEither` to avoid deeply nested `await` blocks and `if (result is Success)` checks.

```dart
import 'package:fpdart/fpdart.dart';

TaskEither<Failure, User> getUserWorkflow() {
  return TaskEither.tryCatch(
    () => api.fetchUser(),
    (error, _) => ServerFailure(error.toString()),
  ).flatMap((user) => validateUser(user));
}
```

## Global Error Catching

Catch "un-catchable" errors that happen outside the Flutter framework (e.g., in async zones) by setting the `PlatformDispatcher` error handler in `main()`.

```dart
void main() {
  PlatformDispatcher.instance.onError = (error, stack) {
    // Log to Sentry or Firebase Crashlytics
    logService.recordError(error, stack);
    return true; // Error was handled
  };

  runApp(const MyApp());
}
```

## Workflow

### Task Progress
- [ ] **Step 1: Define Failures.** Create a hierarchy of failure classes in `core/error/failures.dart`.
- [ ] **Step 2: Setup Result Type.** Add the `Result` sealed class to `core/utils/result.dart`.
- [ ] **Step 3: Handle Data Layer.** Wrap external calls in try/catch and throw custom exceptions.
- [ ] **Step 4: Implement Repository.** Catch custom exceptions and return `Result.success` or `Result.failure`.
- [ ] **Step 5: Pattern Match in BLoC/UI.** Use Dart 3 switch expressions to handle the `Result`.
- [ ] **Step 6: Log Globally.** Configure `PlatformDispatcher.instance.onError` for production logging.

## Example

### Complete Repository Pattern with Result

```dart
// domain/failures.dart
abstract class Failure {
  final String message;
  Failure(this.message);
}
class ServerFailure extends Failure {
  ServerFailure(super.message);
}

// data/repository_impl.dart
@override
Future<Result<List<Item>, Failure>> getItems() async {
  try {
    final items = await remoteDataSource.getItems();
    return Success(items);
  } on ServerException catch (e) {
    return FailureState(ServerFailure(e.message));
  } catch (e) {
    return FailureState(ServerFailure('An unexpected error occurred'));
  }
}
```
