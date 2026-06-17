/// Data-layer exceptions.
///
/// These are thrown by remote data sources and caught by repositories, which
/// then map them to [Failure] objects before returning a [Result].
library;

/// Base class for all data-layer exceptions.
abstract class AppException implements Exception {
  const AppException(this.message, {this.code});

  /// Human-readable description of the error.
  final String message;

  /// Optional error code (e.g. HTTP status code).
  final int? code;

  @override
  String toString() => '$runtimeType(code: $code, message: $message)';
}

/// Thrown when a network / HTTP error occurs (connection, timeout, server).
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

/// Thrown when the server returns a 4xx or 5xx response.
class ServerException extends AppException {
  const ServerException(super.message, {super.code});
}

/// Thrown when the server returns a 401 Unauthorized response.
class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Unauthorized']) : super(code: 401);
}

/// Thrown when the server returns a 403 Forbidden response.
class ForbiddenException extends AppException {
  const ForbiddenException([super.message = 'Forbidden']) : super(code: 403);
}

/// Thrown when the server returns a 404 Not Found response.
class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found']) : super(code: 404);
}

/// Thrown when a request is cancelled.
class RequestCancelledException extends AppException {
  const RequestCancelledException([super.message = 'Request was cancelled']);
}

/// Thrown when the device has no internet connectivity.
class NoInternetException extends AppException {
  const NoInternetException([super.message = 'No internet connection']);
}

/// Thrown when a JSON / data-parsing step fails.
class ParseException extends AppException {
  const ParseException([super.message = 'Failed to parse response']);
}

/// Thrown when a local-cache read/write fails.
class CacheException extends AppException {
  const CacheException([super.message = 'Cache operation failed']);
}
