
import 'package:codebase/src/core/error/failures.dart';

/// A discriminated-union type that represents either a successful [value] or
/// a [failure].
///
/// ### Pattern-match in the presentation layer
/// ```dart
/// final result = await repository.getUser();
///
/// return switch (result) {
///   Success(:final value) => UserProfile(value),
///   Failure(:final failure) => ErrorWidget(failure.message),
/// };
/// ```
sealed class Result<T> {
  const Result();

  /// Returns `true` when this result carries a value.
  bool get isSuccess => this is Success<T>;

  /// Returns `true` when this result carries a failure.
  bool get isFailure => this is ResultFailure<T>;
}

// ── Variants ──────────────────────────────────────────────────────────────────

/// A successful result carrying [value].
final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

/// A failed result carrying a [Failure] descriptor.
///
/// Named [ResultFailure] (not `Failure`) to avoid clashing with the
/// domain [Failure] sealed class.
final class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.failure);

  final Failure failure;
}

// ── Convenience extensions ────────────────────────────────────────────────────

extension ResultX<T> on Result<T> {
  /// Returns the [Success.value] or `null` if this is a failure.
  T? get valueOrNull => switch (this) {
        Success(:final value) => value,
        ResultFailure() => null,
      };

  /// Returns the [ResultFailure.failure] or `null` if this is a success.
  Failure? get failureOrNull => switch (this) {
        Success() => null,
        ResultFailure(:final failure) => failure,
      };

  /// Transforms the [Success.value] with [transform] leaving failures intact.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
        Success(:final value) => Success(transform(value)),
        ResultFailure(:final failure) => ResultFailure<R>(failure),
      };

  /// Calls [onSuccess] or [onFailure] and returns the result.
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) =>
      switch (this) {
        Success(:final value) => onSuccess(value),
        ResultFailure(:final failure) => onFailure(failure),
      };
}

