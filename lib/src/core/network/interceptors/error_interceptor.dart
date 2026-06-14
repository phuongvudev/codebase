import 'dart:io';

import 'package:codebase/src/core/error/exceptions.dart';
import 'package:dio/dio.dart';

/// A Dio interceptor that converts every [DioException] into a typed
/// [AppException] so repositories only need to `catch` the domain exceptions
/// instead of raw Dio errors.
///
/// Exception mapping:
/// | Dio type / HTTP status | Mapped exception              |
/// |------------------------|-------------------------------|
/// | cancel                 | [RequestCancelledException]   |
/// | connectionError /      | [NoInternetException]         |
/// | SocketException        |                               |
/// | connectionTimeout /    | [NetworkException]            |
/// | receiveTimeout /       |                               |
/// | sendTimeout            |                               |
/// | 401                    | [UnauthorizedException]       |
/// | 403                    | [ForbiddenException]          |
/// | 404                    | [NotFoundException]           |
/// | other 4xx / 5xx        | [ServerException]             |
/// | unknown                | [NetworkException]            |
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    throw _mapException(err);
  }

  AppException _mapException(DioException e) {
    // Cancelled request
    if (e.type == DioExceptionType.cancel) {
      return const RequestCancelledException();
    }

    // No internet / socket-level error
    if (e.type == DioExceptionType.connectionError ||
        e.error is SocketException) {
      return const NoInternetException();
    }

    // Timeout
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return NetworkException(
        'Request timed out (${e.type.name})',
        code: e.response?.statusCode,
      );
    }

    // HTTP response error
    if (e.type == DioExceptionType.badResponse) {
      final status = e.response?.statusCode;
      final message = extractMessage(e) ?? e.message ?? 'Server error';

      return switch (status) {
        401 => UnauthorizedException(message),
        403 => ForbiddenException(message),
        404 => NotFoundException(message),
        _ => ServerException(message, code: status),
      };
    }

    // Fallback
    return NetworkException(e.message ?? 'Unexpected network error');
  }

  /// Tries to extract a human-readable message from the response body.
  String? extractMessage(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        return (data['message'] ?? data['error'] ?? data['detail'])?.toString();
      }
    } catch (_) {}
    return null;
  }
}

