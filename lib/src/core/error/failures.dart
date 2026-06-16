/// Domain-layer failures.
///
/// Repositories catch [AppException]s from the data layer and return one of
/// these [Failure] subclasses inside a [Result] so that the presentation layer
/// never has to deal with raw exceptions.
library;

// ── Base ─────────────────────────────────────────────────────────────────────

/// Base sealed class for all domain failures.
sealed class Failure {
  const Failure(this.message, {this.code});

  /// Human-readable description of the failure.
  final String message;

  /// Optional error code (e.g. HTTP status code).
  final int? code;

  @override
  String toString() => '$runtimeType(code: $code, message: $message)';
}

// ── Network ───────────────────────────────────────────────────────────────────

/// A generic network or connectivity failure.
final class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

/// The server responded with a 4xx / 5xx error.
final class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

/// The user is not authenticated (HTTP 401).
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized']) : super(code: 401);
}

/// Access to the resource is denied (HTTP 403).
final class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'Forbidden']) : super(code: 403);
}

/// The requested resource does not exist (HTTP 404).
final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']) : super(code: 404);
}

/// The request was cancelled before it completed.
final class RequestCancelledFailure extends Failure {
  const RequestCancelledFailure([super.message = 'Request was cancelled']);
}

/// The device has no internet connection.
final class NoInternetFailure extends Failure {
  const NoInternetFailure([super.message = 'No internet connection']);
}

// ── Parsing ───────────────────────────────────────────────────────────────────

/// Data could not be parsed from the server response.
final class ParseFailure extends Failure {
  const ParseFailure([super.message = 'Failed to parse response']);
}

// ── Cache & Storage ─────────────────────────────────────────────────────────────

/// A local-cache operation failed.
final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache operation failed']);
}

/// A storage (database/file system) operation failed.
final class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

/// A database-specific operation failed.
final class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

// ── ML & OCR ──────────────────────────────────────────────────────────────────

/// An OCR processing operation failed.
final class OcrFailure extends Failure {
  const OcrFailure(super.message);
}

// ── Business logic ────────────────────────────────────────────────────────────

/// A domain / business-rule validation failed.
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// A generic, unexpected failure.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred']);
}

